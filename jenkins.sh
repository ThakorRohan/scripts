#!/bin/bash

# Updating and Upgrading dependencies
echo "Updating and Upgrading dependencies..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Java
echo "Installing Java..."
sudo apt install fontconfig openjdk-17-jre
java -version

# Add Jenkins Repository
echo "Adding Jenkins Repository..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the system
echo "Updating the system..."
sudo apt-get update -y

# Install Jenkins
echo "Installing Jenkins..."
sudo apt-get install jenkins -y

# Start and Enable Jenkins
echo "Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Output the Jenkins secret password
echo "Installation completed. The Jenkins initial admin password is:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
