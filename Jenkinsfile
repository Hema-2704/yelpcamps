pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = '40448283'
    IMAGE_NAME = 'yelpcamp'
    TAG = "${env.BUILD_ID}"
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
    GIT_CREDENTIALS_ID = 'gits'
  }

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

    stage('Test') {
      steps {
        bat 'echo Skipping tests'
      }
    }

    stage('Build Docker image') {
      when { expression { fileExists('Dockerfile') } }
      steps {
        script {
          def fullImage = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.TAG}"
          bat "docker build -t ${fullImage} ."
        }
      }
    }

    stage('Push Docker image') {
      when { expression { fileExists('Dockerfile') } }
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            def fullImage = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.TAG}"
            bat """
              echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
              docker push ${fullImage}
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo "Done — image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}"
    }
    failure { 
      echo "Build failed" 
    }
  }
}
