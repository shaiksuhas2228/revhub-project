@echo off
setlocal enabledelayedexpansion

echo === RevHub Docker Deployment Script (Windows) ===

if not exist infra-config.properties (
    echo ERROR: infra-config.properties not found!
    exit /b 1
)

echo Loading configuration from infra-config.properties

REM Load properties from file
for /f "tokens=1,2 delims==" %%a in (infra-config.properties) do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" (
        set "%%a=%%b"
    )
)

REM Create Docker network if it doesn't exist
docker network ls --format "{{.Name}}" | findstr /x "%DOCKER_NETWORK%" >nul
if errorlevel 1 (
    echo Creating Docker network: %DOCKER_NETWORK%
    docker network create %DOCKER_NETWORK%
) else (
    echo Docker network %DOCKER_NETWORK% already exists
)

REM Stop and remove old containers
echo Cleaning up old containers...
docker rm -f %MONGO_CONTAINER% %BACKEND_CONTAINER% %FRONTEND_CONTAINER% 2>nul

REM MongoDB
echo.
echo === Starting MongoDB Container ===
docker run -d ^
  --name %MONGO_CONTAINER% ^
  --network %DOCKER_NETWORK% ^
  -p %MONGO_PORT%:27017 ^
  -e MONGO_INITDB_DATABASE=%MONGO_DB% ^
  mongo:6

echo MongoDB started: %MONGO_CONTAINER%

REM Backend
echo.
echo === Building Backend Image ===
docker build -t %BACKEND_IMAGE% .\revHubBack

echo === Starting Backend Container ===
docker run -d ^
  --name %BACKEND_CONTAINER% ^
  --network %DOCKER_NETWORK% ^
  -p %BACKEND_PORT_HOST%:%BACKEND_PORT_CONTAINER% ^
  -e "DB_URL=jdbc:mysql://host.docker.internal:3306/revhubteam7?useSSL=false&allowPublicKeyRetrieval=true" ^
  -e DB_USER=%DB_USER% ^
  -e DB_PASS=%DB_PASS% ^
  -e MONGO_URI=mongodb://%MONGO_HOST%:%MONGO_PORT%/%MONGO_DB% ^
  %BACKEND_IMAGE%

echo Backend started: %BACKEND_CONTAINER%

REM Frontend
echo.
echo === Building Frontend Image ===
docker build -t %FRONTEND_IMAGE% .\RevHub\RevHub

echo === Starting Frontend Container ===
docker run -d ^
  --name %FRONTEND_CONTAINER% ^
  --network %DOCKER_NETWORK% ^
  -p %FRONTEND_PORT_HOST%:%FRONTEND_PORT_CONTAINER% ^
  %FRONTEND_IMAGE%

echo Frontend started: %FRONTEND_CONTAINER%

echo.
echo === Deployment Complete ===
echo MongoDB   : %MONGO_CONTAINER% on network %DOCKER_NETWORK% (port %MONGO_PORT%-^>27017)
echo Backend   : http://localhost:%BACKEND_PORT_HOST%
echo Frontend  : http://localhost:%FRONTEND_PORT_HOST%
echo.
echo To view logs:
echo   docker logs -f %BACKEND_CONTAINER%
echo   docker logs -f %FRONTEND_CONTAINER%
echo   docker logs -f %MONGO_CONTAINER%

endlocal
