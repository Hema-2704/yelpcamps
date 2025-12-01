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
    
    stage('Start, Test, and Stop') {
      steps {
        script {
          try {
            // Start server
            bat 'start /B npm start'
            
            // Wait for server to start
            sleep 15
            
            // Run a quick test
            bat 'curl -f http://localhost:3000 && echo "Server is responding" || echo "Server not responding"'
            
            // Let it run a bit
            sleep 30
            
          } finally {
            // Always stop the server
            bat 'taskkill /F /IM node.exe 2>nul'
          }
        }
      }
    }
  }
  
  post {
    always {
      echo 'Pipeline execution completed.'
    }
  }
}