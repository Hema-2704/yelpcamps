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

    stage('Deploy Container') {
      steps {
        withCredentials([file(credentialsId: 'envfile', variable: 'ENVFILE')]) {
          sh """
            echo 'Loading environment variables...'
            set -a
            source $ENVFILE
            set +a

            echo 'Stopping old container...'
            docker rm -f yelpcamp || true

            echo 'Starting container...'
            docker run -d --name yelpcamp -p 3300:3300 \
              -e MAPBOX_TOKEN="\$MAPBOX_TOKEN" \
              -e DB_URL="\$DB_URL" \
              -e CLOUDINARY_CLOUD_NAME="\$CLOUDINARY_CLOUD_NAME" \
              -e CLOUDINARY_KEY="\$CLOUDINARY_KEY" \
              -e CLOUDINARY_SECRET="\$CLOUDINARY_SECRET" \
              -e SESSION_SECRET="\$SESSION_SECRET" \
              ${IMAGE}:${TAG}
          """
        }
      }
    }
  }

  post {
    success {
      echo "Build & Deploy SUCCEEDED"
    }
    failure {
      echo "Build FAILED"
    }
    always {
      sh "docker image prune -af || true"
    }
  }
}
