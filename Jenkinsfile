pipeline {
    agent any
    
    tools {
        nodejs "NodeJS"
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
                bat 'npm ci --legacy-peer-deps'
            }
        }
        
        stage('Run Tests') {
            steps {
                bat 'npm test'
            }
        }
        
        stage('Security Audit') {
            steps {
                bat 'npm audit --audit-level moderate'
            }
        }
        
        stage('Stop Previous App') {
            steps {
                bat '''
                    echo Stopping any existing YelpCamp process...
                    taskkill /f /im node.exe 2>nul || exit 0
                    timeout /t 5 /nobreak
                '''
            }
        }
        
        stage('Start Application') {
            steps {
                bat """
                    echo Starting YelpCamp application...
                    start /b node app.js > yelpcamp.log 2>&1
                    echo Application started in background
                """
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sleep time: 15, unit: 'SECONDS'
                    bat """
                        echo Performing health check...
                        curl -f http://localhost:%PORT%/ || curl -f http://localhost:%PORT%/campgrounds
                        if %errorlevel% equ 0 (
                            echo ✅ YelpCamp is healthy and responding on port %PORT%
                        ) else (
                            echo ❌ Health check failed
                            type yelpcamp.log
                            exit 1
                        )
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ YelpCamp deployed successfully! Running on port ${PORT}"
        }
        failure {
            echo "❌ Deployment failed"
            bat '''
                echo === Application Logs ===
                type yelpcamp.log
                echo === Current Processes ===
                tasklist | findstr node
            '''
        }
        always {
            archiveArtifacts artifacts: 'yelpcamp.log', onlyIfSuccessful: false
        }
    }
}