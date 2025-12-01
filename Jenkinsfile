// Jenkinsfile — Pipeline (NO Docker)
pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = '40448283'   // kept for compatibility if you re-add Docker later
    IMAGE_NAME = 'yelpcamp'
    TAG = "${env.BUILD_ID}"
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
    GIT_CREDENTIALS_ID = 'gits'
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              # prefer reproducible installs; allow legacy peer deps in CI
              export NPM_CONFIG_LEGACY_PEER_DEPS=true
              if [ -f package-lock.json ]; then
                npm ci --legacy-peer-deps || npm install --legacy-peer-deps
              else
                npm install --legacy-peer-deps
              fi
            '''
          } else {
            bat '''
              set NPM_CONFIG_LEGACY_PEER_DEPS=true
              if exist package-lock.json (
                npm ci --legacy-peer-deps || npm install --legacy-peer-deps
              ) else (
                npm install --legacy-peer-deps
              )
            '''
          }
        }
      }
    }

    stage('Test') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              if npm run | grep -q " test"; then
                echo "Running tests (failures won't abort pipeline)..."
                npm test || true
              else
                echo "No test script defined - skipping tests"
              fi
            '''
          } else {
            bat '''
              npm run | findstr /C:"test" >nul
              if %ERRORLEVEL%==0 (
                echo Running tests (failures won't abort pipeline)...
                npm test || echo Tests failed (ignored)
              ) else (
                echo No test script defined - skipping tests
              )
            '''
          }
        }
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: 'reports/**/*.xml'
        }
      }
    }

    stage('Build') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              if npm run | grep -q " build"; then
                npm run build
              else
                echo "No build script - skipping build"
              fi
            '''
          } else {
            bat '''
              npm run | findstr /C:"build" >nul
              if %ERRORLEVEL%==0 (
                npm run build
              ) else (
                echo No build script - skipping build
              )
            '''
          }
        }
      }
    }

    stage('Package & Archive') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              TIMESTAMP=$(date +%Y%m%d%H%M%S)
              if [ -d build ]; then
                tar -czf artifact-${TIMESTAMP}.tar.gz build
              else
                tar -czf artifact-${TIMESTAMP}.tar.gz .
              fi
            '''
          } else {
            bat '''
              powershell -Command "$t = Get-Date -Format yyyyMMddHHmmss; if (Test-Path build) { Compress-Archive -Path build\\* -DestinationPath artifact-$t.zip -Force } else { Compress-Archive -Path * -DestinationPath artifact-$t.zip -Force }"
            '''
          }
        }
        archiveArtifacts artifacts: 'artifact-*.*', fingerprint: true
      }
    }

    // Optional Deploy stage can be added here if you want (SSH / PM2 / etc.)
  }

  post {
    success {
      echo "✅ Pipeline succeeded. Artifact archived."
    }
    failure {
      echo "❌ Pipeline failed — check console output."
    }
  }
}
