#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Update packages
echo "Updating packages..."
apt update && apt upgrade -y

# Install necessary system utilities
echo "Installing system utilities..."
apt install -y git curl jq docker.io docker-compose

# Run MariaDB in a container
echo "Starting MariaDB container..."
docker run -d \
   --name postal-mariadb \
   -p 127.0.0.1:3306:3306 \
   --restart always \
   -e MARIADB_DATABASE=postal \
   -e MARIADB_ROOT_PASSWORD=postal \
   mariadb

# Clone the Postal installation helper repository
echo "Cloning Postal installation helper repository..."
git clone https://github.com/postalserver/install /opt/postal/install
ln -s /opt/postal/install/bin/postal /usr/bin/postal

# Bootstrap Postal
read -p "Enter your domain (e.g., example.com): " DOMAIN
echo "Bootstrapping Postal for domain postal.$DOMAIN..."
postal bootstrap postal.$DOMAIN

# Initialize Postal
echo "Initializing Postal..."
postal initialize

# Create Postal user
echo "Creating Postal user..."
postal make-user

# Start Postal
echo "Starting Postal..."
postal start

# Run Caddy in a container
echo "Starting Caddy container..."
docker run -d \
   --name postal-caddy \
   --restart always \
   --network host \
   -v /opt/postal/config/Caddyfile:/etc/caddy/Caddyfile \
   -v /opt/postal/caddy-data:/data \
   caddy

echo "DONE"
