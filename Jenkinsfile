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

        stage('Upload artifact & Configure') {
            steps {
                sshagent (credentials: [env.SSH_CREDENTIALS]) {
                    script {
                        sh """
                          ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} \
                          'sudo mkdir -p ${REMOTE_APP_DIR} && sudo chown ${EC2_USER}:${EC2_USER} ${REMOTE_APP_DIR}'
                        """

                        // Upload JAR from correct folder
                        sh """
                          scp -o StrictHostKeyChecking=no JtProject/target/*.jar \
                          ${EC2_USER}@${EC2_HOST}:${REMOTE_APP_DIR}/app.jar
                        """

                        def service = """
                        [Unit]
                        Description=Ecommerce Spring Boot
