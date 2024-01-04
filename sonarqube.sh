#!/bin/bash

# Update and Upgrade the System
echo "Updating and upgrading the system..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Remove existing SonarQube installation (if any)
echo "Checking for existing SonarQube installation..."
if [ -d "/opt/sonarqube" ]; then
    echo "Removing existing SonarQube installation..."
    sudo systemctl stop sonarqube
    sudo rm -rf /opt/sonarqube
    sudo rm /etc/systemd/system/sonarqube.service
    sudo systemctl daemon-reload
fi

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get install postgresql postgresql-contrib -y

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Before PostgreSQL commands
pushd /tmp > /dev/null

# Create SonarQube Database and User
echo "Creating SonarQube database and user..."
sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"

# After PostgreSQL commands
popd > /dev/null

# Download SonarQube
echo "Downloading SonarQube..."
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.3.0.82913.zip

# Install Unzip
sudo apt-get install unzip -y

# Unzip SonarQube
sudo unzip sonarqube-10.3.0.82913.zip -d /opt

# Rename SonarQube directory
sudo mv /opt/sonarqube-10.3.0.82913 /opt/sonarqube

# Configure SonarQube
# Update the sonar.properties file for database configuration
echo "Configuring SonarQube..."
sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.url=jdbc:postgresql:\/\/localhost\/sonarqube/sonar.jdbc.url=jdbc:postgresql:\/\/localhost\/sonarqube/' /opt/sonarqube/conf/sonar.properties

# Add Systemd service for SonarQube
echo "Creating Systemd service for SonarQube..."
echo "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonar
Group=sonar
PermissionsStartOnly=true
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonarqube.service

# Reload Systemd
sudo systemctl daemon-reload

# Start SonarQube
echo "Starting SonarQube..."
sudo systemctl start sonarqube
sudo systemctl enable sonarqube

echo "SonarQube installation and configuration completed."
