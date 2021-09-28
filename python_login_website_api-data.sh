#!/bin/bash

# Install apache2
sudo apt update -y
sudo apt install apache2 -y
sudo apt install apache2-utils -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo bash -c 'echo your very first web server > /var/www/html/index.html'


# Installing PHP
sudo apt install php libapache2-mod-php -y
sudo systemctl restart apache2 -y
sudo apt install php-fpm -y
sudo apt install php-mysql php-gd -y

# Installing MariaDB
apt -y install mariadb-server
db_root_password=secret
mysql_secure_installation <<EOF
y
$db_root_password
$db_root_password
y
y
y
y
EOF



# Install Docker on Ubuntu from official Repository
sudo apt update -y 
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt update -y
sudo apt-get install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker




# Installing Docker on Amazon Linux
#sudo yum update -y
#sudo amazon-linux-extras install docker
#sudo yum install docker
#sudo service docker start
#sudo usermod -a -G docker ec2-user

