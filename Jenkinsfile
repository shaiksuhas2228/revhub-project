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
                echo 'Skipping properties load - using environment variables from Docker run command'
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
                        sh 'docker ps'
                        sh 'docker logs revhub-backend --tail 50'
                        sh 'curl -f http://localhost:8080/ || echo "Backend not ready yet"'
                    } else {
                        bat 'docker ps'
                        bat 'docker logs revhub-backend --tail 50'
                        bat 'curl -f http://localhost:8080/ || echo Backend not ready yet'
                    }
                }
                echo 'Health check complete'
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
            echo 'Frontend: http://localhost:4200'
            echo 'Backend: http://localhost:8080'
        }
        failure {
            echo 'Deployment failed. Check logs for details.'
            script {
                if (isUnix()) {
                    sh 'docker ps -a || true'
                    sh 'docker logs revhub-backend --tail 100 || true'
                } else {
                    bat 'docker ps -a || exit 0'
                    bat 'docker logs revhub-backend --tail 100 || exit 0'
                }
            }
        }
        always {
            echo 'Pipeline execution completed'
        }
    }
}
