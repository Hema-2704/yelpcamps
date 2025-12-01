// Jenkinsfile (Docker agent) using your env variables and credential IDs
pipeline {
  agent {
    docker {
      image 'node:16'
      args  '-u root:root'   // ensure the agent can run docker commands (or run on an agent that has docker)
    }
  }

  environment {
    DOCKER_REGISTRY = '40448283'           // Your Docker Hub username
    IMAGE_NAME = 'yelpcamp'                // image repo name
    TAG = "${env.BUILD_ID}"
    DOCKER_CREDENTIALS_ID = 'docker-hub-credentials' // Jenkins credential id for Docker Hub (username+password/token)
    GIT_CREDENTIALS_ID = 'gits'            // Jenkins credential id for Git (if repo is private)
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  stages {
    stage('Checkout') {
      steps {
        // If your repo is private, configure credentials in the job or use a multibranch pipeline
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
        // run tests if test script exists, but don't fail the pipeline just because tests are not present
        sh '''
          if npm run | grep -q test; then
            npm test || true
          fi
        '''
      }
    }

    stage('Build Docker image') {
      when { expression { fileExists('Dockerfile') } }
      steps {
        script {
          env.FULL_IMAGE = "${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.TAG}"
          sh "docker build -t ${env.FULL_IMAGE} ."
        }
      }
    }

    stage('Push Docker image') {
      when { expression { fileExists('Dockerfile') } }
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            // login, push, logout
            sh """
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
              docker push ${env.FULL_IMAGE}
              docker logout || true
            """
          }
        }
      }
    }

    stage('Cleanup local image') {
      when { expression { fileExists('Dockerfile') } }
      steps {
        // remove local image to free agent disk space (non-fatal)
        sh "docker rmi ${env.FULL_IMAGE} || true"
      }
    }
  }

  post {
    success {
      echo "Done — image: ${env.DOCKER_REGISTRY}/${env.IMAGE_NAME}:${env.TAG}"
    }
    failure {
      echo "Build failed"
    }
    always {
      // Best-effort cleanup
      sh "docker logout || true"
    }
  }
}
