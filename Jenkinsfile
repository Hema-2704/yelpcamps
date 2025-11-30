pipeline {
    agent any
    
    environment {
        CI = 'true'
    }
    
    stages {
        stage('Setup Node.js') {
            steps {
                sh '''
                    # Install Node.js if not present
                    if ! command -v node &> /dev/null; then
                        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                    fi
                    echo "Node: $(node --version)"
                    echo "NPM: $(npm --version)"
                '''
            }
        }
        
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Hema-2704/yelpcamps.git'
            }
        }
        
        stage('Install & Test') {
            steps {
                sh 'npm install'
                sh 'npm audit --production || true'
            }
        }
        
        stage('Start App') {
            steps {
                sh '''
                    npm start &
                    sleep 20
                    pkill -f "node.*app.js" || true
                '''
            }
        }
        
        stage('Package') {
            steps {
                sh 'tar -czf yelpcamps-${BUILD_NUMBER}.tar.gz . --exclude=node_modules'
                archiveArtifacts 'yelpcamps-*.tar.gz'
            }
        }
    }
}