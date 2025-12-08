#!/bin/bash
# EC2 Initial Setup Script
set -e

echo "=== RevHub EC2 Setup ==="

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo apt install -y docker-compose

# Install Git
sudo apt install -y git

# Install Java 17 (for backend build if needed)
sudo apt install -y openjdk-17-jdk maven

# Install Node.js 20 (for frontend build)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install MySQL
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

echo "=== Setup Complete ==="
echo "IMPORTANT: Logout and login again for docker permissions"
