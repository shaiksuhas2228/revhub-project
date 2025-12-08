# EC2 Deployment Guide

## Prerequisites
- Your EC2 key file (e.g., `your-key.pem`)
- EC2 IP: `3.17.60.182`

## Step-by-Step Deployment

### 1. Connect to EC2
```bash
ssh -i your-key.pem ubuntu@3.17.60.182
```

### 2. First Time Setup (if project not cloned yet)
```bash
# Clone repository
git clone https://github.com/shaiksuhas2228/p1.git
cd p1
git checkout version1

# Install dependencies
sudo apt update
sudo apt install -y docker.io docker-compose maven nodejs npm
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

**Important:** After adding user to docker group, logout and login again:
```bash
exit
ssh -i your-key.pem ubuntu@3.17.60.182
```

### 3. Deploy Application
```bash
cd ~/p1

# Pull latest changes
git pull origin version1

# Build Frontend
cd RevHub/RevHub/RevHub
npm install
npm run build -- --configuration production

# Build Backend
cd ../../../revHubBack
mvn clean package -DskipTests

# Deploy with Docker
cd ..
chmod +x run-docker.sh
./run-docker.sh
```

### 4. Verify Deployment
```bash
# Check running containers
docker ps

# Check logs
docker logs revhub-backend
docker logs revhub-frontend
docker logs revhub-mongodb
```

### 5. Access Application
- Frontend: http://3.17.60.182:4200
- Backend API: http://3.17.60.182:8080

## Quick Redeploy Script
For faster redeployment, use the provided script:
```bash
cd ~/p1
chmod +x deploy-to-ec2.sh
./deploy-to-ec2.sh
```

## Troubleshooting

### Port Already in Use
```bash
# Stop existing containers
docker stop revhub-backend revhub-frontend revhub-mongodb
docker rm revhub-backend revhub-frontend revhub-mongodb

# Or kill processes on ports
sudo lsof -ti:4200 | xargs kill -9
sudo lsof -ti:8080 | xargs kill -9
sudo lsof -ti:27017 | xargs kill -9
```

### Docker Permission Denied
```bash
sudo usermod -aG docker ubuntu
exit
# Login again
```

### Build Failures
```bash
# Clean and rebuild
cd ~/p1/RevHub/RevHub/RevHub
rm -rf node_modules dist
npm install
npm run build -- --configuration production

cd ~/p1/revHubBack
mvn clean install -DskipTests
```

### View Real-time Logs
```bash
docker logs -f revhub-backend
docker logs -f revhub-frontend
```

## Manual Commands Reference

### Stop All Services
```bash
docker stop revhub-backend revhub-frontend revhub-mongodb
```

### Remove All Containers
```bash
docker rm revhub-backend revhub-frontend revhub-mongodb
```

### Restart Services
```bash
cd ~/p1
./run-docker.sh
```

### Check System Resources
```bash
df -h          # Disk space
free -h        # Memory
docker stats   # Container resources
```
