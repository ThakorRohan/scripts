#!/bin/bash

# Variables for Jenkins admin user
JENKINS_ADMIN_USER="admin"
JENKINS_ADMIN_PASS="22012006@Rr"

# Updating and Upgrading dependencies
echo "Updating and Upgrading dependencies..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Java
echo "Installing Java..."
sudo apt install -y fontconfig openjdk-17-jre
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

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker.io

# Add Jenkins user to Docker group
echo "Adding Jenkins user to Docker group..."
sudo usermod -aG docker root
sudo usermod -aG docker jenkins

# Restart Jenkins to apply changes
echo "Restarting Jenkins..."
sudo systemctl restart jenkins

# Create the Groovy script for adding the Jenkins admin user
cat <<EOF > create_jenkins_admin.groovy
import jenkins.model.*
import hudson.security.*

def jenkinsInstance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount("$JENKINS_ADMIN_USER", "$JENKINS_ADMIN_PASS")
jenkinsInstance.setSecurityRealm(hudsonRealm)
jenkinsInstance.save()
EOF

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
while ! curl --output /dev/null --silent --head --fail http://localhost:8080; do
    printf '.'
    sleep 5
done
echo "Jenkins started."

# Run the Groovy script to create the Jenkins admin user
echo "Creating admin user in Jenkins..."
sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ groovy = < create_jenkins_admin.groovy

# Output the Jenkins secret password
echo "Installation completed. The Jenkins initial admin password is:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
