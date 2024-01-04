#!/bin/bash

# Update and Upgrade the System
echo "Updating and upgrading the system..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Docker if not already installed
echo "Installing Docker..."
sudo apt install docker.io -y

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Create Docker volumes for SonarQube data and extensions
echo "Creating Docker volumes for SonarQube..."
sudo docker volume create sonarqube_data
sudo docker volume create sonarqube_extensions

# Run SonarQube Docker container
echo "Starting SonarQube Docker container..."
sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  sonarqube:latest

# Install Sonar-Scanner (local analysis tool)
echo "Installing Sonar-Scanner..."
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip
sudo unzip sonar-scanner-cli-4.6.2.2472-linux.zip -d /opt
sudo ln -s /opt/sonar-scanner-4.6.2.2472-linux/bin/sonar-scanner /usr/bin/sonar-scanner

echo "SonarQube and Sonar-Scanner installation completed."
