provider "aws" {
    region = "us-east-1"    
}

## 1. Create a VPC
resource "aws_vpc" "python_login_website-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.tag_name
  }
}

## 2. Create Internet Gateway
resource "aws_internet_gateway" "python_login_website-gw" {
  vpc_id = aws_vpc.python_login_website-vpc.id

  tags = {
    Name = var.tag_name
  }
}
## 3. Create Custom Route Table
resource "aws_route_table" "python_login_website-route-table" {
  vpc_id = aws_vpc.python_login_website-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.python_login_website-gw.id
  }
  
  route {
      ipv6_cidr_block        = "::/0"
      gateway_id = aws_internet_gateway.python_login_website-gw.id
    }

  tags = {
    Name = var.tag_name
  }
}

## 4. Create a Subnet
resource "aws_subnet" "python_login_website-subnet" {
  vpc_id     = aws_vpc.python_login_website-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = var.tag_name
  }
}

## 5. Associate Subnet with the Route Teble
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.python_login_website-subnet.id
  route_table_id = aws_route_table.python_login_website-route-table.id

}


## 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "python_login_website-allow-http-https-traffic" {
  name        = "allow_http_https"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.python_login_website-vpc.id

  ingress {
      description      = "HTTPS from VPC"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
      description      = "HTTP from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
      description      = "Database access Port"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.tag_name
  }
}


## 7. Create a Network Interface with an IP in the Subnet that was created in Step 4
resource "aws_network_interface" "python_login_website-net-server-nic" {
  subnet_id       = aws_subnet.python_login_website-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.python_login_website-allow-http-https-traffic.id]

  tags = {
    Name = var.tag_name
  }
}

## 8. Assigh an Elastic IP to the Network Interface created in Step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.python_login_website-net-server-nic.id
  associate_with_private_ip = "10.0.1.50"

  tags = {
    Name = var.tag_name
  }
}


## 9. Create an Ubuntu Server and Install/Apache2
 resource "aws_instance" "python_login_website-server-instance" {
   ami               = var.ami_id
   instance_type     = var.instance_type
   #availability_zone = "us-east-1d"
   key_name          = var.key_name
   network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.python_login_website-net-server-nic.id
   }
   #Options
   #user_data = file("${path.module}/files/api-data.sh")
   #and inside the api-data.sh put all the commands you want to run on the instance
   user_data = "${file("python_login_website_api-data.sh")}"

  # Copies webapp folder file to /var/www/html
   provisioner "file" {
     source      = "webapp/"
     destination = "/var/www/html"
  }

  # Copies default-ssl.conf to /etc/apache2/sites-enabled/
   provisioner "file" {
     content     = "apache2/default-ssl.conf"
     destination = "/etc/apache2/sites-enabled/"
  }

  # Copies apache2.conf to /etc/apache2/apache2.conf
   provisioner "file" {
     source      = "apache2/apache2.conf"
     destination = "/etc/apache2/apache2.conf"
  }

   tags = {
     Name = var.tag_name
   }
 }


