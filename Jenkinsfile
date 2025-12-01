pipeline {
  agent any

  environment {
    NODE_ENV = 'production'
    GIT_CREDENTIALS_ID = 'gits'        // optional: if your git repo is private
    DEPLOY_SSH_CREDENTIALS = 'deploy-ssh' // optional: Jenkins SSH credential id for deployment
    DEPLOY_USER = 'deployuser'         // override in job if needed
    DEPLOY_HOST = 'your.server.example'// override in job if needed
    DEPLOY_PATH = '/opt/yelpcamp'      // where to place the build on target host
  }

  stages {
    stage('Checkout') {
      steps {
        // if your repo is private and you configured credentials for the job,
        // "checkout scm" will use the job's configured credentials.
        checkout scm
      }
    }

    stage('Prepare') {
      steps {
        // show versions for debugging agent setup
        sh 'node --version || true'
        sh 'npm --version || true'
      }
    }

    stage('Install') {
      steps {
        // Use npm ci for reproducible installs if package-lock.json exists
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
        // run tests only if npm has a test script
        sh '''
          if npm run | grep -q " test"; then
            npm test || true
          else
            echo "No test script defined — skipping tests"
          fi
        '''
      }
      post {
        always {
          // collect junit if tests produce it; adjust path if needed
          junit allowEmptyResults: true, testResults: 'reports/**/*.xml'
        }
      }
    }

    stage('Build') {
      steps {
        // build only if script exists
        sh '''
          if npm run | grep -q " build"; then
            npm run build
          else
            echo "No build script - packaging current workspace"
            mkdir -p build
            cp -r * build || true
          fi
        '''
        // create a single artifact to archive
        sh '''
          TIMESTAMP=$(date +%Y%m%d%H%M%S)
          if [ -d build ]; then
            tar -czf release-$TIMESTAMP.tar.gz build
          else
            tar -czf release-$TIMESTAMP.tar.gz .
          fi
        '''
        archiveArtifacts artifacts: 'release-*.tar.gz', fingerprint: true
      }
    }

    stage('Deploy (optional)') {
      when {
        expression { return env.DEPLOY_HOST != null && env.DEPLOY_HOST != '' }
      }
      steps {
        // requires Jenkins credential of type "SSH Username with private key" with id DEPLOY_SSH_CREDENTIALS
        sshagent (credentials: [env.DEPLOY_SSH_CREDENTIALS]) {
          sh '''
            LATEST=$(ls -1t release-*.tar.gz | head -n1)
            echo "Deploying $LATEST to ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}"
            scp -o StrictHostKeyChecking=no $LATEST ${DEPLOY_USER}@${DEPLOY_HOST}:/tmp/
            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} "mkdir -p ${DEPLOY_PATH} && tar -xzf /tmp/$LATEST -C ${DEPLOY_PATH} && systemctl restart yelpcamp || true"
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded. Artifact archived."
    }
    failure {
      echo "Pipeline failed. See console output."
    }
  }
}
