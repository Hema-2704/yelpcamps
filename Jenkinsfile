pipeline {
    agent any
    
    tools {
        nodejs "nodejs"
    }
    
    environment {
        NODE_ENV = 'production'
        PORT = '3300'
    }
    
    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm ci --legacy-peer-deps'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Security Audit') {
            steps {
                sh 'npm audit --audit-level moderate'
            }
        }
        
        stage('Stop Previous App') {
            steps {
                sh '''
                    echo "Stopping any existing YelpCamp process..."
                    pkill -f "node.*app.js" || true
                    sleep 5
                '''
            }
        }
        
        stage('Start Application') {
            steps {
                sh """
                    echo "Starting YelpCamp application..."
                    nohup node app.js > yelpcamp.log 2>&1 &
                    echo \$! > yelpcamp.pid
                    echo "Application started with PID: \$(cat yelpcamp.pid)"
                """
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sleep time: 15, unit: 'SECONDS'
                    sh """
                        echo "Performing health check..."
                        if curl -f http://localhost:\${PORT}/ || curl -f http://localhost:\${PORT}/campgrounds; then
                            echo "✅ YelpCamp is healthy and responding on port \${PORT}"
                        else
                            echo "❌ Health check failed"
                            echo "=== Application Logs ==="
                            cat yelpcamp.log || true
                            exit 1
                        fi
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ YelpCamp deployed successfully! Running on port \${PORT}"
        }
        failure {
            echo "❌ Deployment failed"
            sh '''
                echo "=== Application Logs ==="
                cat yelpcamp.log || true
                echo "=== Current Processes ==="
                ps aux | grep node || true
            '''
        }
        always {
            archiveArtifacts artifacts: 'yelpcamp.log', onlyIfSuccessful: false
        }
    }
}