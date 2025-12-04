pipeline {
    agent any

    tools {
        maven 'M3'
    }

    environment {
        EC2_USER = 'ec2-user'
        EC2_HOST = "${params.EC2_HOST}"
        SSH_CREDENTIALS = 'ec2-ssh'
        RDS_ENDPOINT = "${params.RDS_ENDPOINT}"
        DB_USERNAME = "${params.DB_USERNAME}"
        DB_PASSWORD = "${params.DB_PASSWORD}"
        REMOTE_APP_DIR = "/opt/ecommerce"
    }

    parameters {
        string(name: 'EC2_HOST', description: 'EC2 Public IP')
        string(name: 'RDS_ENDPOINT', description: 'RDS endpoint')
        string(name: 'DB_USERNAME', defaultValue: 'ecomadmin')
        password(name: 'DB_PASSWORD', defaultValue: '')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                dir('JtProject') {
                    sh "mvn -B -DskipTests clean package"
                }
            }
        }

        stage('Upload Artifact and Configure') {
            steps {
                sshagent (credentials: [env.SSH_CREDENTIALS]) {
                    script {

                        sh "ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'sudo mkdir -p ${REMOTE_APP_DIR} && sudo chown ${EC2_USER}:${EC2_USER} ${REMOTE_APP_DIR}'"

                        sh "scp -o StrictHostKeyChecking=no JtProject/target/*.jar ${EC2_USER}@${EC2_HOST}:${REMOTE_APP_DIR}/app.jar"

                        sh '''
                        ssh -o StrictHostKeyChecking=no ''' + "${EC2_USER}@${EC2_HOST}" + ''' 'sudo bash -c "cat > /etc/systemd/system/ecommerce.service <<EOF
[Unit]
Description=Ecommerce Spring Boot App
After=network.target

[Service]
User=''' + "${EC2_USER}" + '''
WorkingDirectory=''' + "${REMOTE_APP_DIR}" + '''
ExecStart=/usr/bin/java -jar ''' + "${REMOTE_APP_DIR}" + '''/app.jar --spring.datasource.url=jdbc:mysql://''' + "${RDS_ENDPOINT}" + ''':3306/ecomdb --spring.datasource.username=''' + "${DB_USERNAME}" + ''' --spring.datasource.password=''' + "${DB_PASSWORD}" + '''
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"'
                        '''

                        sh "ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'sudo systemctl daemon-reload && sudo systemctl restart ecommerce.service'"
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                sh "sleep 10"
                sh "ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'curl -s --fail http://localhost:8080/ || exit 1'"
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}
