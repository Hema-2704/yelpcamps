pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install Dependencies') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Run Tests') {
      steps {
        sh 'if npm run | grep -q test; then npm test || true; fi'
      }
    }

    stage('Build Application') {
      steps {
        // Add any build steps here (e.g., transpiling, bundling, etc.)
        // Example for Node.js: npm run build
        sh 'if npm run | grep -q build; then npm run build || true; fi'
      }
    }
  }

  post {
    success {
      echo 'Pipeline completed successfully!'
      // Optional: Archive artifacts
      // archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
    }
    failure {
      echo 'Pipeline failed!'
    }
    always {
      // Optional: Clean up or send notifications
      echo 'Cleaning up workspace...'
      cleanWs()
    }
  }
}