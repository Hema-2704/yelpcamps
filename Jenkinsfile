pipeline {
    agent any
    
    tools {
        nodejs "nodejs"
    }
    
    environment {
        // You can override .env values here if needed
        CI = 'true'
    }
    
    stages {
        stage('Checkout & Validate') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/Hema-2704/yelpcamps.git'
                
                script {
                    // Verify essential files exist
                    if (!fileExists('.env')) {
                        error("❌ .env file not found in repository")
                    }
                    if (!fileExists('app.js')) {
                        error("❌ app.js file not found")
                    }
                    echo "✅ All required files present"
                }
            }
        }
        
        stage('Install & Audit') {
            steps {
                sh 'npm install'
                sh 'npm audit --production'  // Check only production dependencies
            }
        }
        
        stage('Environment Check') {
            steps {
                sh '''
                    echo "=== Environment File Contents (masked) ==="
                    # Show .env structure without revealing secrets
                    if [ -f .env ]; then
                        while IFS= read -r line; do
                            if [[ $line == *"="* ]]; then
                                key=$(echo $line | cut -d'=' -f1)
                                value=$(echo $line | cut -d'=' -f2-)
                                if [[ ${#value} -gt 2 ]]; then
                                    masked_value="${value:0:2}****${value: -2}"
                                else
                                    masked_value="****"
                                fi
                                echo "${key}=${masked_value}"
                            else
                                echo "$line"
                            fi
                        done < .env
                    fi
                    echo "=========================================="
                '''
            }
        }
        
        stage('Application Test') {
            steps {
                sh '''
                    # Test if application can start without errors
                    echo "Testing application startup..."
                    # Start in background and capture output
                    npm start > server.log 2>&1 &
                    SERVER_PID=$!
                    
                    # Wait a bit for server to start or fail
                    sleep 15
                    
                    # Check if process is still running
                    if ps -p $SERVER_PID > /dev/null; then
                        echo "✅ Application started successfully"
                        # Stop the server
                        kill $SERVER_PID
                    else
                        echo "❌ Application failed to start"
                        echo "=== Server Log ==="
                        cat server.log
                        echo "=================="
                        exit 1
                    fi
                '''
            }
        }
        
        stage('Create Deployment Package') {
            steps {
                sh '''
                    # Create clean build without node_modules
                    tar -czf summercamp-${BUILD_NUMBER}.tar.gz \
                        --exclude=node_modules \
                        --exclude=.git \
                        --exclude=*.log \
                        .
                '''
                archiveArtifacts artifacts: 'summercamp-*.tar.gz', fingerprint: true
            }
        }
    }
    
    post {
        always {
            sh 'pkill -f "node.*app.js" || true'  // Ensure cleanup
            sh 'rm -f server.log || true'
        }
        success {
            echo "🎉 SummerCamp build successful!"
            // Add notifications here if needed
        }
        unstable {
            echo "⚠️  Build completed with warnings"
        }
        failure {
            echo "💥 Build failed - check logs for details"
        }
    }
}