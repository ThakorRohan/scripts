#!/bin/bash

# Updating and Upgrading dependencies
echo "Updating and Upgrading dependencies..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Java
echo "Installing Java..."
sudo apt-get install openjdk-11-jdk -y

# Add Jenkins Repository
echo "Adding Jenkins Repository..."
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

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
