// Jenkinsfile (No Docker — simple pipeline, Windows-friendly)
pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = '40448283'           // kept for compatibility with original file
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
        // use legacy peer deps to avoid npm ERESOLVE in CI
        bat '''
        set NPM_CONFIG_LEGACY_PEER_DEPS=true
        if exist package-lock.json (
          npm ci
        ) else (
          npm install
        )
        '''
      }
    }

    stage('Test') {
      steps {
        // run tests only if package.json defines a test script
        bat '''
        npm run | findstr /C:"test" >nul
        if %ERRORLEVEL%==0 (
          npm test
        ) else (
          echo No test script defined - skipping tests
        )
        '''
      }
      post {
        always {
          // adjust path if your tests produce JUnit XML reports
          junit allowEmptyResults: true, testResults: 'reports/**/*.xml'
        }
      }
    }

    stage('Build') {
      steps {
        bat '''
        npm run | findstr /C:"build" >nul
        if %ERRORLEVEL%==0 (
          npm run build
          REM assume build output in "build" or "dist" — change if needed
        ) else (
          echo No build script - packaging workspace as-is
        )
        '''
      }
    }

    stage('Package & Archive') {
      steps {
        // create a zip of the workspace (PowerShell Compress-Archive)
        bat '''
        powershell -Command "Compress-Archive -Path . -DestinationPath ${env.WORKSPACE}\\artifact-${env.BUILD_ID}.zip -Force"
        '''
        archiveArtifacts artifacts: "artifact-${env.BUILD_ID}.zip", fingerprint: true
      }
    }

    // Optional: simple deploy stage (comment/uncomment and configure if you need)
    // stage('Deploy') {
    //   when { expression { return env.DEPLOY_HOST != null && env.DEPLOY_HOST != '' } }
    //   steps {
    //     sshagent (credentials: ['deploy-ssh']) {
    //       bat '''
    //       REM Example: copy artifact to linux host (requires scp on Windows agent)
    //       scp -o StrictHostKeyChecking=no artifact-${env.BUILD_ID}.zip user@yourhost:/tmp/
    //       '''
    //     }
    //   }
    // }

  }

  post {
    success {
      echo "✅ Pipeline succeeded — artifact: artifact-${env.BUILD_ID}.zip"
    }
    failure {
      echo "❌ Pipeline failed — check console output"
    }
  }
}
