#!/bin/bash
set -e

# Update & install Java and git
yum update -y || apt-get update -y
# Amazon Linux 2
if command -v yum >/dev/null 2>&1; then
  yum install -y java-11-amazon-corretto git
else
  apt-get install -y openjdk-11-jre-headless git
fi

mkdir -p /opt/ecommerce
chown ec2-user:ec2-user /opt/ecommerce

# Create systemd service
cat > /etc/systemd/system/ecommerce.service <<'EOF'
[Unit]
Description=Ecommerce Spring Boot App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/opt/ecommerce
ExecStart=/usr/bin/java -jar /opt/ecommerce/app.jar --spring.datasource.url=jdbc:mysql://${RDS_ENDPOINT}:3306/ecomdb --spring.datasource.username=${DB_USERNAME} --spring.datasource.password=${DB_PASSWORD}
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable service (will fail until jar exists; mask then unmask later)
systemctl daemon-reload
systemctl enable ecommerce.service || true

# Placeholders for environment variables: we'll replace them when Jenkins deploys the jar
touch /opt/ecommerce/DEPLOY_INFO
chown ec2-user:ec2-user /opt/ecommerce/DEPLOY_INFO

