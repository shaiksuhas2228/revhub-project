pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Load Infrastructure Properties') {
            steps {
                script {
                    echo 'Loading infra-config.properties...'
                    def props = readProperties file: 'infra-config.properties'
                    props.each { k, v ->
                        env."${k}" = v
                    }
                    echo "Loaded ${props.size()} properties"
                }
            }
        }

        stage('Build Backend') {
            steps {
                echo 'Building Spring Boot backend...'
                dir('revHubBack') {
                    script {
                        if (isUnix()) {
                            sh 'mvn clean package -DskipTests'
                        } else {
                            bat 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }

        stage('Build Frontend') {
            steps {
                echo 'Building Angular frontend...'
                dir('RevHub/RevHub') {
                    script {
                        if (isUnix()) {
                            sh 'npm install'
                            sh 'npm run build -- --configuration production'
                        } else {
                            bat 'npm install'
                            bat 'npm run build -- --configuration production'
                        }
                    }
                }
            }
        }

        stage('Deploy with Docker') {
            steps {
                echo 'Deploying containers...'
                script {
                    if (isUnix()) {
                        sh 'chmod +x run-docker.sh'
                        sh './run-docker.sh'
                    } else {
                        bat 'run-docker.bat'
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo 'Waiting for services to start...'
                sleep time: 30, unit: 'SECONDS'
                script {
                    if (isUnix()) {
                        sh 'curl -f http://localhost:8080/actuator/health || exit 1'
                    } else {
                        bat 'curl -f http://localhost:8080/actuator/health || exit 1'
                    }
                }
                echo 'Backend health check passed'
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
            echo "Frontend: http://localhost:${env.FRONTEND_PORT_HOST}"
            echo "Backend: http://localhost:${env.BACKEND_PORT_HOST}"
        }
        failure {
            echo 'Deployment failed. Check logs for details.'
            script {
                if (isUnix()) {
                    sh 'docker logs ${BACKEND_CONTAINER} || true'
                } else {
                    bat 'docker logs %BACKEND_CONTAINER% || exit 0'
                }
            }
        }
    }
}
