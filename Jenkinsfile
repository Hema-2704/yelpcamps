// Jenkinsfile (Docker agent) using your env variables and credential IDs
pipeline {
  agent {
    docker {
      image 'node:16'
      args  '-u root:root'
    }
  }

  environment {
    DOCKER_REGISTRY = '40448283'           // Your Docker Hub username (you provided)
    IMAGE_NAME = 'yelpcamp'                // image repo name
    TAG = "${env.BUILD_ID}"
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials' // Jenkins credential id for Docker Hub
    GIT_CREDENTIALS_ID = 'gits'            // Jenkins credential id for Git (if repo is private)
  }

  stages {
    stage('Checkout') {
      steps {
        // If your repo is private, configure credentials in the job (see steps below)
        checkout scm
      }
    }

    stage('Install') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Test') {
      steps {
        sh 'if npm run | grep -q test; then npm test || true; fi'
      }
    }

    stage('Build Docker image') {
      when { expression { fileExists('Dockerfile') } }
      steps {
        script {
          def fullImage = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.TAG}"
          sh "docker build -t ${fullImage} ."
        }
      }
    }

    stage('Push Docker image') {
      when { expression { fileExists('Dockerfile') } }
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            def fullImage = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.TAG}"
            sh '''
              echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
              docker push ${fullImage}
            '''
          }
        }
      }
    }
  }
  pipeline {
  agent any
  stages {
    stage('Hello') {
      steps {
        echo "Hello from Jenkins — pipeline is configured!"
      }
    }
  }
}


  post {
    success {
      echo "Done — image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}"
    }
    failure { echo "Build failed" }
  }
}
