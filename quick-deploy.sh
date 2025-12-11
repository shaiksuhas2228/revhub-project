#!/bin/bash
set -e

echo "=== RevHub Quick Deploy ==="

# Navigate to project
cd ~/p1

# Pull latest code
git pull origin version1

# Copy EC2 config
cp ec2-infra-config.properties infra-config.properties

# Build backend
cd revHubBack
mvn clean package -DskipTests
cd ..

# Build frontend
cd RevHub/RevHub
npm install
npm run build -- --configuration production
cd ../..

# Deploy with Docker
chmod +x run-docker.sh
./run-docker.sh

echo "=== Deployment Complete ==="
echo "Frontend: http://3.151.228.198:4200"
echo "Backend: http://3.151.228.198:8080"