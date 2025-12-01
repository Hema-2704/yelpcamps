pipeline {
  agent any
  
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    
    stage('Install') {
      steps {
        bat 'npm install'
      }
    }
    
    stage('Start on Port 3300') {
      steps {
        script {
          // Start server
          bat 'start /B npm start'
          
          // Wait and test
          sleep 40
          
          bat '''
            echo "Testing server on port 3300..."
            curl http://localhost:3300 || echo "Server might need more time to start"
          '''
          
          // Keep it running for testing
          sleep 60
        }
      }
    }
  }
  
  post {
    always {
      echo 'Stopping server...'
      bat 'taskkill /F /IM node.exe 2>nul'
      echo 'Done!'
    }
  }
}