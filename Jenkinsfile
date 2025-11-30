pipeline {
  agent any

  environment {
    REGISTRY = "docker.io/40448283"
    IMAGE = "${REGISTRY}/yelpcamp"
    TAG = "${env.BUILD_NUMBER}"
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install & Test') {
      steps {
        sh '''
          docker run --rm \
            -v "$PWD":/app \
            -w /app \
            node:18-alpine \
            sh -c "npm ci --legacy-peer-deps && npm test || true"
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE}:${TAG} ."
      }
    }

    stage('Login to Registry') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-registry-credentials',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS')]) {

          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
        }
      }
    }

    stage('Push Image') {
      steps {
        sh "docker push ${IMAGE}:${TAG}"
      }
    }
  }

  post {
    success {
      echo "Build SUCCEEDED"
    }
    failure {
      echo "Build FAILED"
    }
    always {
      sh "docker image prune -af || true"
    }
  }
}
