# RevHub EC2 Deployment Guide

**EC2 IP:** 18.118.83.64  
**Key File:** C:\aws-keys\revhub-key.pem

---

## STEP 1: Connect to EC2 from Windows

Open PowerShell and run:

```powershell
cd C:\aws-keys
ssh -i revhub-key.pem ubuntu@18.118.83.64
```

If permission error, run:
```powershell
icacls revhub-key.pem /inheritance:r
icacls revhub-key.pem /grant:r "%username%:R"
```

---

## STEP 2: Initial EC2 Setup (Run on EC2)

```bash
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

# Install Java 17
sudo apt install -y openjdk-17-jdk maven

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install MySQL
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

# IMPORTANT: Logout and login again
exit
```

Then reconnect:
```powershell
ssh -i revhub-key.pem ubuntu@18.118.83.64
```

---

## STEP 3: Setup MySQL Database (Run on EC2)

```bash
sudo mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS revhubteam7;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
EOF
```

---

## STEP 4: Clone Repository (Run on EC2)

```bash
cd ~
git clone https://github.com/shaiksuhas2228/p1.git
cd p1
git checkout version1
```

---

## STEP 5: Copy EC2 Config File (Run on EC2)

```bash
cd ~/p1
cp ec2-infra-config.properties infra-config.properties
```

---

## STEP 6: Build Backend (Run on EC2)

```bash
cd ~/p1/revHubBack
mvn clean package -DskipTests
```

---

## STEP 7: Build Frontend (Run on EC2)

```bash
cd ~/p1/RevHub/RevHub
npm install
npm run build -- --configuration production
```

---

## STEP 8: Deploy with Docker (Run on EC2)

```bash
cd ~/p1
chmod +x run-docker.sh
./run-docker.sh
```

---

## STEP 9: Access Application

- **Frontend:** http://18.118.83.64:4200
- **Backend:** http://18.118.83.64:8080

---

## Troubleshooting Commands

```bash
# Check containers
docker ps

# View logs
docker logs -f revhub-backend
docker logs -f revhub-frontend
docker logs -f revhub-mongodb

# Restart deployment
cd ~/p1
docker stop revhub-backend revhub-frontend revhub-mongodb
docker rm revhub-backend revhub-frontend revhub-mongodb
./run-docker.sh

# Check MySQL
sudo mysql -u root -proot -e "SHOW DATABASES;"
```
