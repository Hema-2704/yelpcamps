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
    
    stage('Start') {
      steps {
        bat 'npm start'
      }
    }
  }
  
  post {
    always {
      echo 'Done!'
    }
  }
}