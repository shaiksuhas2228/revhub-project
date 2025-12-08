# RevHub EC2 Commands Guide

**EC2 IP:** 3.151.228.198 (Elastic IP)  
**Key File:** C:\aws-keys\revhub-key.pem

---

## Connect to EC2

```powershell
# From Windows PowerShell
cd C:\aws-keys
ssh -i revhub-key.pem ubuntu@3.151.228.198
```

---

## START Application

```bash
# Start all containers in order
docker start revhub-mysql
sleep 5
docker start revhub-mongodb
docker start revhub-backend
docker start revhub-frontend

# Check if all running
docker ps
```

---

## STOP Application

```bash
# Stop all containers
docker stop revhub-frontend revhub-backend revhub-mongodb revhub-mysql
```

---

## RESTART Application

```bash
# Restart all containers
docker restart revhub-mysql
sleep 5
docker restart revhub-mongodb
docker restart revhub-backend
docker restart revhub-frontend
```

---

## CHECK Status

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# Check backend logs
docker logs revhub-backend

# Check frontend logs
docker logs revhub-frontend

# Check MySQL logs
docker logs revhub-mysql

# Check MongoDB logs
docker logs revhub-mongodb

# Follow logs in real-time
docker logs -f revhub-backend
```

---

## REDEPLOY After Code Changes

```bash
# 1. Connect to EC2
ssh -i revhub-key.pem ubuntu@3.151.228.198

# 2. Pull latest code
cd ~/p1
git pull origin version1

# 3. Rebuild Backend
cd revHubBack
mvn clean package -DskipTests
cd ..

# 4. Rebuild Frontend
cd RevHub/RevHub
npm install
npm run build -- --configuration production
cd ../..

# 5. Stop and remove old containers
docker stop revhub-backend revhub-frontend
docker rm revhub-backend revhub-frontend

# 6. Remove old images
docker rmi revhub-backend revhub-frontend

# 7. Build new images
docker build -t revhub-backend ./revHubBack
docker build -t revhub-frontend ./RevHub/RevHub

# 8. Start new containers
docker run -d \
  --name revhub-backend \
  --network revhub-net \
  -p 8080:8080 \
  -e DB_URL="jdbc:mysql://revhub-mysql:3306/revhubteam7?useSSL=false&allowPublicKeyRetrieval=true" \
  -e DB_USER="root" \
  -e DB_PASS="root" \
  -e MONGO_URI="mongodb://revhub-mongodb:27017/revhubteam4" \
  revhub-backend

docker run -d \
  --name revhub-frontend \
  --network revhub-net \
  -p 4200:80 \
  revhub-frontend

# 9. Check logs
docker logs -f revhub-backend
```

---

## COMPLETE CLEANUP (Remove Everything)

```bash
# Stop all containers
docker stop revhub-frontend revhub-backend revhub-mongodb revhub-mysql

# Remove all containers
docker rm revhub-frontend revhub-backend revhub-mongodb revhub-mysql

# Remove all images
docker rmi revhub-backend revhub-frontend mysql:8.0 mongo:6

# Remove network
docker network rm revhub-net
```

---

## FRESH DEPLOYMENT (From Scratch)

```bash
# 1. Create network
docker network create revhub-net

# 2. Start MySQL
docker run -d \
  --name revhub-mysql \
  --network revhub-net \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=revhubteam7 \
  mysql:8.0

# Wait for MySQL to start
sleep 15

# 3. Start MongoDB
docker run -d \
  --name revhub-mongodb \
  --network revhub-net \
  -p 27017:27017 \
  -e MONGO_INITDB_DATABASE=revhubteam4 \
  mongo:6

# 4. Build and start Backend
cd ~/p1
docker build -t revhub-backend ./revHubBack

docker run -d \
  --name revhub-backend \
  --network revhub-net \
  -p 8080:8080 \
  -e DB_URL="jdbc:mysql://revhub-mysql:3306/revhubteam7?useSSL=false&allowPublicKeyRetrieval=true" \
  -e DB_USER="root" \
  -e DB_PASS="root" \
  -e MONGO_URI="mongodb://revhub-mongodb:27017/revhubteam4" \
  revhub-backend

# 5. Build and start Frontend
docker build -t revhub-frontend ./RevHub/RevHub

docker run -d \
  --name revhub-frontend \
  --network revhub-net \
  -p 4200:80 \
  revhub-frontend

# 6. Verify
docker ps
docker logs revhub-backend
```

---

## TROUBLESHOOTING

### Backend won't start
```bash
# Check logs
docker logs revhub-backend

# Restart MySQL first
docker restart revhub-mysql
sleep 10
docker restart revhub-backend
```

### Frontend not loading
```bash
# Check if container is running
docker ps | grep frontend

# Restart frontend
docker restart revhub-frontend

# Check logs
docker logs revhub-frontend
```

### Database connection issues
```bash
# Check MySQL is running
docker ps | grep mysql

# Check MySQL logs
docker logs revhub-mysql

# Restart MySQL and backend
docker restart revhub-mysql
sleep 10
docker restart revhub-backend
```

### Port already in use
```bash
# Check what's using the port
sudo netstat -tulpn | grep 8080

# Kill process if needed
sudo kill -9 <PID>

# Or stop the container
docker stop revhub-backend
```

---

## ACCESS APPLICATION

- **Frontend:** http://3.151.228.198:4200
- **Backend API:** http://3.151.228.198:8080

---

## DISCONNECT FROM EC2

```bash
exit
```
