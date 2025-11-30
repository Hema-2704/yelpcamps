pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'   // change this if not Node.js
            }
        }

        stage('Run App') {
            steps {
                sh 'npm start'     // or your command: python app.py, nodemon, etc.
            }
        }
    }
}
