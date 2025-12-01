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
        sh '''
          if [ -f package-lock.json ]; then
            npm ci
          else
            npm install
          fi
        '''
      }
    }

    stage('Test') {
      steps {
        sh '''
          if npm run | grep -q " test"; then
            npm test
          else
            echo "No tests found — skipping"
          fi
        '''
      }
    }

    stage('Build') {
      steps {
        sh '''
          if npm run | grep -q " build"; then
            npm run build
          else
            echo "No build step — skipping"
          fi
        '''
      }
    }

    stage('Archive') {
      steps {
        sh '''
          TIMESTAMP=$(date +%Y%m%d%H%M%S)
          tar -czf build-$TIMESTAMP.tar.gz .
        '''
        archiveArtifacts artifacts: 'build-*.tar.gz', fingerprint: true
      }
    }

  }

  post {
    success {
      echo "🎉 Pipeline completed successfully!"
    }
    failure {
      echo "❌ Pipeline failed. Check logs."
    }
  }
}
