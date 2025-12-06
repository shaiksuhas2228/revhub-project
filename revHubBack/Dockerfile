# Backend Dockerfile for Spring Boot
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copy the built jar (Maven creates revHubBack-0.0.1-SNAPSHOT.jar based on pom.xml)
COPY target/revHubBack-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

# Environment variables with defaults (overridden at runtime)
ENV DB_URL=jdbc:mysql://host.docker.internal:3306/revhubteam7?useSSL=false&allowPublicKeyRetrieval=true
ENV DB_USER=root
ENV DB_PASS=root
ENV MONGO_URI=mongodb://mongodb:27017/revhubteam4

ENTRYPOINT ["java", "-jar", "app.jar"]
