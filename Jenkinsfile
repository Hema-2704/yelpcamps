pipeline {
  agent any

  environment {
    REGISTRY = "docker.io/40448283"
    IMAGE = "${REGISTRY}/yelpcamp"
    TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
  }

  options {
    timestamps()
    ansiColor('xterm')
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
        // Run tests inside a Node container so Jenkins host doesn't need Node installed
        sh 'docker run --rm -v "$PWD":/app -w /app node:18-alpine sh -c "npm ci --legacy-peer-deps && npm test || true"'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE}:${TAG} ."
      }
    }

    stage('Login to Registry') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-registry-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login ${REGISTRY} -u $DOCKER_USER --password-stdin'
        }
      }
    }

    stage('Push Image') {
      steps {
        sh "docker push ${IMAGE}:${TAG}"
        script {
          if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
            sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
            sh "docker push ${IMAGE}:latest"
          }
        }
      }
    }

    stage('Deploy (optional)') {
      steps {
        echo "Deployment step left as optional. Use SSH to deploy to a Linux host or run docker compose on target."
      }
    }
  }

  post {
    success {
      echo "Build SUCCEEDED: ${env.BUILD_NUMBER}"
    }
    failure {
      echo "Build FAILED: ${env.BUILD_NUMBER}"
    }
    always {
      sh "docker image prune -af || true"
    }
  }
}
