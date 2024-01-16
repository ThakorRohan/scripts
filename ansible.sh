#!/bin/bash

# Update system package list
echo "Updating system package list..."
sudo apt update

# Install software-properties-common
echo "Installing software-properties-common..."
sudo apt install -y software-properties-common

# Add Ansible PPA
echo "Adding Ansible PPA..."
sudo add-apt-repository --yes --update ppa:ansible/ansible

# Update package list again
echo "Updating package list..."
sudo apt update

# Install Ansible
echo "Installing Ansible..."
sudo apt install -y ansible

# Create a basic Ansible configuration
echo "Creating basic Ansible configuration file..."
echo "[defaults]
inventory = /etc/ansible/hosts
remote_user = ubuntu" | sudo tee /etc/ansible/ansible.cfg

# Create a basic inventory file
echo "Creating basic Ansible inventory file..."
echo "[servers]
server1 ansible_host=192.168.1.100
server2 ansible_host=192.168.1.101" | sudo tee /etc/ansible/hosts

echo "Ansible installation and basic configuration complete."
