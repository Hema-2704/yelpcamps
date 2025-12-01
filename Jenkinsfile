pipeline {
  agent any
  
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    
    stage('Install & Build') {
      steps {
        bat '''
          npm install
          npm run build --if-present
        '''
      }
    }
  }
  
  post {
    always {
      echo 'Done!'
    }
  }
}