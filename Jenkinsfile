pipeline {
  agent {
    docker { image 'maven:3.9.6-eclipse-temurin-17' }
  }

  stages {
    stage('Build') {
      steps {
        sh "mvn -B -DskipTests clean package"
      }
    }
  }

  environment {
    EC2_USER = 'ec2-user'
    EC2_HOST = "${params.EC2_HOST}"    // set as pipeline param or Jenkins credentials/variable
    SSH_CREDENTIALS = 'ec2-ssh'        // Jenkins SSH key credentials id
    RDS_ENDPOINT = "${params.RDS_ENDPOINT}" // set at pipeline run or use Jenkins variable
    DB_USERNAME = "${params.DB_USERNAME}"
    DB_PASSWORD = "${params.DB_PASSWORD}" // mark as secret in Jenkins
    APP_JAR = "target/ecommerce-0.0.1-SNAPSHOT.jar" // adjust to actual artifact name
    REMOTE_APP_DIR = "/opt/ecommerce"
  }

  parameters {
    string(name: 'EC2_HOST', defaultValue: '', description: 'EC2 public IP or DNS')
    string(name: 'RDS_ENDPOINT', defaultValue: '', description: 'RDS endpoint')
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
        sh "mvn -B -DskipTests clean package"
      }
    }

    stage('Upload artifact & configure') {
      steps {
        sshagent (credentials: [env.SSH_CREDENTIALS]) {
          script {
            // Create remote dir
            sh "ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'sudo mkdir -p ${REMOTE_APP_DIR} && sudo chown ${EC2_USER}:${EC2_USER} ${REMOTE_APP_DIR}'"

            // Copy jar
            sh "scp -o StrictHostKeyChecking=no ${APP_JAR} ${EC2_USER}@${EC2_HOST}:${REMOTE_APP_DIR}/app.jar"

            // Create systemd service on remote with concrete values
            def service = """
            [Unit]
            Description=Ecommerce Spring Boot App
            After=network.target

            [Service]
            User=${EC2_USER}
            WorkingDirectory=${REMOTE_APP_DIR}
            ExecStart=/usr/bin/java -jar ${REMOTE_APP_DIR}/app.jar --spring.datasource.url=jdbc:mysql://${RDS_ENDPOINT}:3306/ecomdb --spring.datasource.username=${DB_USERNAME} --spring.datasource.password=${DB_PASSWORD}
            SuccessExitStatus=143
            Restart=always
            RestartSec=10

            [Install]
            WantedBy=multi-user.target
            """

            // Write service file remotely and restart
            sh "ssh ${EC2_USER}@${EC2_HOST} 'echo \"${service}\" | sudo tee /etc/systemd/system/ecommerce.service > /dev/null'"
            sh "ssh ${EC2_USER}@${EC2_HOST} 'sudo systemctl daemon-reload && sudo systemctl enable ecommerce.service && sudo systemctl restart ecommerce.service'"
          }
        }
      }
    }

    stage('Health check') {
      steps {
        sh "sleep 8"
        sh "ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'curl -sS --fail http://localhost:8080/actuator/health || curl -sS --fail http://localhost:8080/'"
      }
    }
  }

  post {
    success {
      echo "Deployment succeeded"
    }
    failure {
      echo "Deployment failed"
    }
  }
}

