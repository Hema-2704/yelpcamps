pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install') {
            steps {
                bat """
                if exist package-lock.json (
                    npm ci
                ) else (
                    npm install
                )
                """
            }
        }

        stage('Test') {
            steps {
                bat """
                npm run | findstr /C:"test" >nul
                if %ERRORLEVEL%==0 (
                    npm test
                ) else (
                    echo No tests found - skipping
                )
                """
            }
        }

        stage('Build') {
            steps {
                bat """
                npm run | findstr /C:"build" >nul
                if %ERRORLEVEL%==0 (
                    npm run build
                ) else (
                    echo No build script - skipping
                )
                """
            }
        }

        stage('Archive') {
            steps {
                bat """
                powershell -Command "Compress-Archive -Path . -DestinationPath build.zip -Force"
                """
                archiveArtifacts artifacts: 'build.zip', fingerprint: true
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
