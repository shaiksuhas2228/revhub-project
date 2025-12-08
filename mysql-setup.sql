-- MySQL Setup for RevHub
CREATE DATABASE IF NOT EXISTS revhubteam7;
USE revhubteam7;

-- Grant permissions
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
