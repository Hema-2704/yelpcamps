pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = '40448283'  // Your Docker Hub username
        IMAGE_NAME = 'yelpcamp'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        GIT_CREDENTIALS_ID = 'gits'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: env.GIT_CREDENTIALS_ID,
                    url: 'https://github.com/Hema-2704/yelpcamps.git'  // ← FIX THIS
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the image with proper tagging
                    docker.build("${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    docker.image("${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}").inside {
                        sh 'npm test'  // Make sure you have test script in package.json
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    sh "docker scan ${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_CREDENTIALS_ID) {
                        docker.image("${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}").push()
                        docker.image("${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:latest").push()
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                script {
                    sh """
                    docker stop yelpcamp-staging || true
                    docker rm yelpcamp-staging || true
                    docker run -d \
                        --name yelpcamp-staging \
                        -p 3000:3000 \
                        -e NODE_ENV=staging \
                        ${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                script {
                    // Wait for app to start
                    sleep 30
                    // Run integration tests - adjust endpoint as needed
                    sh 'curl -f http://localhost:3000/ || exit 1'  // Changed from /health
                }
            }
        }
    }
    
    post {
        always {
            // Clean up staging container
            sh 'docker stop yelpcamp-staging || true'
            sh 'docker rm yelpcamp-staging || true'
            
            // Clean up Docker images to save space
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully!'
            // emailext ( // Commented out until email is configured
            //     subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
            //     body: "The build ${env.BUILD_URL} completed successfully.",
            //     to: "developer@yourcompany.com"
            // )
        }
        failure {
            echo 'Pipeline failed!'
            // emailext (
            //     subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
            //     body: "The build ${env.BUILD_URL} failed. Please check the console output.",
            //     to: "developer@yourcompany.com"
            // )
        }
    }
}