pipeline {
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    agent any

    stages {
        stage('Checkout') {
            steps {
            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/fculibao/python_login_website.git']]])            

          }
        }
        stage ("terraform init") {
            steps {
                sh ('/usr/local/bin/terraform init')
            }
        }
        
        stage ("terraform Action") {
            steps {
                echo "Terraform action is --> ${action}"
                sh ('/usr/local/bin/terraform ${action} --auto-approve')
           }
        }
        stage ("Move Config Files") {
            steps {
                sh '''
                    #!/bin/bash
                    sleep 30
                    instance=`/usr/local/bin/terraform state show aws_eip.one | grep public_ip | awk 'NR==1{print $3}' | sed 's/"//g' `
                    #cd /var/lib/jenkins/workspace/python_login_website
                    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=accept-new 2> /dev/null -r /var/lib/jenkins/workspace/python_login_website/webapp -i /home/ec2-user/.ssh/myinanpang-keypair01.pem ubuntu@"${instance}":/var/www/htmp

                    #cd /var/lib/jenkins/workspace/python_login_website/apache2/
                    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=accept-new 2> /dev/null /var/lib/jenkins/workspace/python_login_website/apache2/* -i /home/ec2-user/.ssh/myinanpang-keypair01.pem ubuntu@"${instance}":/var/www/htmp

                '''
            }
        }    
    }
}