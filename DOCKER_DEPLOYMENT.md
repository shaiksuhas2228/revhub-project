# RevHub Docker Deployment Guide

## Architecture Overview

- **MongoDB Container**: Database for chat and notifications
- **Backend Container**: Spring Boot API (Java 17)
- **Frontend Container**: Angular app served via Nginx
- **MySQL**: External database (host or RDS)

All containers communicate via Docker network `revhub-net`.

## Prerequisites

1. Docker installed and running
2. MySQL running on host (or accessible via network)
3. Maven installed (for backend build)
4. Node.js & npm installed (for frontend build)

## Quick Start

### 1. Configure Credentials

Edit `infra-config.properties` and update:
```properties
DB_USER=your_mysql_username
DB_PASS=your_mysql_password
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
```

### 2. Build Applications

**Backend:**
```bash
cd revHubBack
mvn clean package -DskipTests
cd ..
```

**Frontend:**
```bash
cd RevHub/RevHub
npm install
npm run build -- --configuration production
cd ../..
```

### 3. Deploy Containers

**Linux/Mac:**
```bash
chmod +x run-docker.sh
./run-docker.sh
```

**Windows:**
```cmd
run-docker.bat
```

### 4. Access Application

- Frontend: http://localhost:4200
- Backend API: http://localhost:8080
- MongoDB: localhost:27017

## Container Details

### MongoDB
- **Image**: mongo:6
- **Container Name**: revhub-mongodb
- **Port**: 27017
- **Database**: revhubteam4
- **Network**: revhub-net

### Backend
- **Image**: revhub-backend
- **Container Name**: revhub-backend
- **Port**: 8080
- **Network**: revhub-net
- **Environment Variables**:
  - `DB_URL`: MySQL connection string
  - `DB_USER`: MySQL username
  - `DB_PASS`: MySQL password
  - `MONGO_URI`: MongoDB connection string

### Frontend
- **Image**: revhub-frontend
- **Container Name**: revhub-frontend
- **Port**: 4200 (mapped to container port 80)
- **Network**: revhub-net

## Connection Details

### Backend → MySQL
Uses `host.docker.internal` to access MySQL on host machine:
```
jdbc:mysql://host.docker.internal:3306/revhubteam7
```

### Backend → MongoDB
Uses container name as hostname within Docker network:
```
mongodb://mongodb:27017/revhubteam4
```

### Frontend → Backend
Browser makes requests to backend via host port mapping:
```
http://localhost:8080
```

## Useful Commands

### View Logs
```bash
docker logs -f revhub-backend
docker logs -f revhub-frontend
docker logs -f revhub-mongodb
```

### Stop All Containers
```bash
docker stop revhub-backend revhub-frontend revhub-mongodb
```

### Remove All Containers
```bash
docker rm revhub-backend revhub-frontend revhub-mongodb
```

### Remove Network
```bash
docker network rm revhub-net
```

### Rebuild Single Container
```bash
# Backend
docker stop revhub-backend && docker rm revhub-backend
docker build -t revhub-backend ./revHubBack
docker run -d --name revhub-backend --network revhub-net -p 8080:8080 \
  -e DB_URL="..." -e DB_USER="..." -e DB_PASS="..." \
  -e MONGO_URI="mongodb://mongodb:27017/revhubteam4" \
  revhub-backend

# Frontend
docker stop revhub-frontend && docker rm revhub-frontend
docker build -t revhub-frontend ./RevHub/RevHub
docker run -d --name revhub-frontend --network revhub-net -p 4200:80 revhub-frontend
```

## Jenkins CI/CD

The `Jenkinsfile` automates the entire deployment:

1. Checks out code from Git
2. Loads `infra-config.properties`
3. Builds backend JAR with Maven
4. Builds frontend with npm
5. Executes deployment script
6. Performs health check

### Jenkins Setup

1. Create new Pipeline job
2. Point to your Git repository
3. Ensure Jenkins agent has Docker, Maven, and Node.js installed
4. Run the pipeline

## Troubleshooting

### Backend can't connect to MySQL
- Ensure MySQL is running on host
- Check `DB_URL` uses `host.docker.internal` (not `localhost`)
- Verify MySQL allows connections from Docker subnet

### Backend can't connect to MongoDB
- Ensure MongoDB container is running: `docker ps | grep mongodb`
- Check containers are on same network: `docker network inspect revhub-net`
- Verify `MONGO_URI` uses container name `mongodb` as hostname

### Frontend can't reach backend
- Check backend is accessible: `curl http://localhost:8080/actuator/health`
- Verify Angular environment points to `http://localhost:8080`
- Check browser console for CORS errors

### Port already in use
- Stop conflicting services or change ports in `infra-config.properties`
- Check what's using the port: `netstat -ano | findstr :8080` (Windows) or `lsof -i :8080` (Linux/Mac)

## Production Considerations

1. **Secrets Management**: Use Docker secrets or external secret manager instead of plain text in properties file
2. **Persistent Storage**: Add volumes for MongoDB data persistence
3. **Reverse Proxy**: Use Nginx/Traefik in front of containers
4. **SSL/TLS**: Configure HTTPS certificates
5. **Resource Limits**: Set memory and CPU limits for containers
6. **Health Checks**: Add Docker HEALTHCHECK instructions to Dockerfiles
7. **Logging**: Configure centralized logging (ELK stack, CloudWatch, etc.)
8. **Monitoring**: Add Prometheus/Grafana for metrics

## File Structure

```
RevHub/
├── infra-config.properties    # Central configuration
├── run-docker.sh              # Linux/Mac deployment script
├── run-docker.bat             # Windows deployment script
├── Jenkinsfile                # CI/CD pipeline
├── DOCKER_DEPLOYMENT.md       # This file
├── revHubBack/
│   ├── Dockerfile             # Backend container definition
│   ├── pom.xml
│   └── src/
└── RevHub/RevHub/
    ├── Dockerfile             # Frontend container definition
    ├── package.json
    └── src/
```
