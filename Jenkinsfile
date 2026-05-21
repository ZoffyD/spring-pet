pipeline {
    agent any

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Source Code Management') {
            steps {
                checkout scm
            }
        }

        stage('Build & Compile') {
            steps {
                script {
                    // Compiles code, runs validations, and builds the executable .jar file
                    bat 'mvn clean package -DskipTests'
                }
            }
        }

        stage('E2E Testing (Cypress)') {
            steps {
                script {
                    // 1. Pre-kill any stale processes hanging on port 8081 from previous failed builds
                    echo "Clearing port 8081..."
                    bat 'powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }; exit 0"'

                    // 2. Start the app in the background using JDK 21 from JAVA_HOME (the bare 'java' on PATH is Java 11 and cannot run this jar)
                    echo "Launching Spring Boot App in background (JDK 21)..."
                    bat 'start "" /B "%JAVA_HOME%\\bin\\java" -jar "%WORKSPACE%\\target\\spring-petclinic-4.0.0-SNAPSHOT.jar" --server.port=8081'

                    // 3. Wait-for-health loop: Polls the actuator endpoint until the server is awake (Max 120s)
                    echo "Waiting for server to become healthy on port 8081..."
                    bat 'powershell -NoProfile -Command "for ($i=0; $i -lt 60; $i++) { try { Invoke-WebRequest -UseBasicParsing http://localhost:8081/actuator/health -TimeoutSec 3 | Out-Null; Write-Host \'App is up on 8081\'; exit 0 } catch { Start-Sleep -Seconds 2 } }; Write-Host \'App did not start on 8081 within 120s\'; exit 1"' 

                    // 4. Install Node dependencies and execute Cypress End-to-End tests
                    echo "Running Cypress UI automation suite..."
                    bat 'npm install'
                    bat 'npx cypress run --config baseUrl=http://localhost:8081'
                }
            }
            post {
                always {
                    script {
                        // 5. Clean up: Ensure the background Java server process is turned off after testing completes
                        echo "Cleaning up environment: Stopping background server..."
                        bat 'powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }; exit 0"'
                    }
                }
            }
        }

        stage('Performance Testing (JMeter)') {
            steps {
                echo "Running Performance Metrics via JMeter..."
                // Add your JMeter execution commands here if needed
            }
        }

        stage('Deploy (Local Docker Compose)') {
            steps {
                echo "Deploying application stack..."
                // Add your final deployment commands here if needed
            }
        }
    }

    post {
        always {
            // Records unit test reports and charts framework execution results
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
        }
    }
}