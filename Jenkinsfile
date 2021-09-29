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
                    instance=(/usr/local/bin/terraform state show aws_eip.one | grep public_ip | awk 'NR==1{print $3}' | sed 's/"//g')
                    cd /var/lib/jenkins/workspace/python_login_website
                    scp -r webapp -i ~/.ssh/myinanpang-keypair01.pem ec2-user@"${instance}":/var/www/htmp/

                    cd /var/lib/jenkins/workspace/python_login_website/apache2/
                    scp * -i ~/.ssh/myinanpang-keypair01.pem ec2-user@"${instance}":/var/www/htmp/

                '''
            }
        }    
    }
}