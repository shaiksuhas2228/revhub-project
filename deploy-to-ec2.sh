#!/bin/bash

# RevHub EC2 Deployment Script
# Run this script on your EC2 instance

set -e

echo "=== RevHub EC2 Deployment ==="
echo "Starting deployment process..."

# Navigate to project directory
cd ~/p1

# Pull latest code
echo "Pulling latest code from GitHub..."
git pull origin version1

# Build Frontend
echo "Building Angular frontend..."
cd RevHub/RevHub/RevHub
npm install
npm run build -- --configuration production

# Build Backend
echo "Building Spring Boot backend..."
cd ../../../revHubBack
mvn clean package -DskipTests

# Deploy with Docker
echo "Deploying with Docker..."
cd ..
chmod +x run-docker.sh
./run-docker.sh

echo "=== Deployment Complete ==="
echo "Frontend: http://3.17.60.182:4200"
echo "Backend: http://3.17.60.182:8080"
