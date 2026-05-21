pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        IMAGE_NAME = 'petclinic'
        // Ephemeral port used to test the freshly built jar (Cypress + JMeter).
        // The real deployment runs on 8080 (see docker-compose.deploy.yml).
        TEST_PORT  = '8081'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // CI: compile + run unit tests. PostgresIntegrationTests is excluded
        // in pom.xml, so a plain build is green. If any test fails, the
        // pipeline stops here and nothing gets deployed.
        stage('Build & Unit Test') {
            steps {
                bat 'mvnw.cmd clean package'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        // Start the packaged jar on TEST_PORT so the E2E and perf stages have
        // a live app to hit. Security autoconfig is disabled to match the
        // existing Cypress specs.
        stage('Start App for Testing') {
            steps {
                bat '''
                    for %%f in (target\\*.jar) do (
                        start /B java -Dserver.port=%TEST_PORT% ^
                            -Dspring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration ^
                            -jar "%%f"
                    )
                '''
                echo 'Waiting 50s for the app to start...'
                sleep 50
            }
        }

        stage('E2E Testing (Cypress)') {
            steps {
                bat 'npm ci'
                bat 'npx cypress run --browser electron --config baseUrl=http://localhost:%TEST_PORT%'
            }
        }

        // Light, fast perf check against the test jar using the parameterized
        // plan. The heavy 500-thread plans in src/test/jmeter are for manual runs.
        stage('Performance Testing (JMeter)') {
            steps {
                bat 'jmeter -n -t petclinic-loadtest.jmx -Jhost=localhost -Jport=%TEST_PORT% -Jusers=20 -Jrampup=5 -Jloops=5 -l target\\jmeter-results.jtl'
            }
        }

        // Free up the test app before deploying, so port cleanup never touches
        // the deployed container.
        stage('Stop Test App') {
            steps {
                bat '''
                    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%TEST_PORT% ^| findstr LISTENING') do (
                        taskkill /F /PID %%a 2>nul
                    )
                    exit 0
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t %IMAGE_NAME%:%BUILD_NUMBER% -t %IMAGE_NAME%:latest .'
                bat 'docker images %IMAGE_NAME%'
            }
        }

        // CD: deploy the freshly built image with docker compose. The image is
        // already on this host's Docker daemon, so no registry push is needed.
        stage('Deploy (Docker Compose)') {
            steps {
                bat 'docker compose -f docker-compose.deploy.yml down --remove-orphans'
                bat 'docker compose -f docker-compose.deploy.yml up -d'
                echo 'Waiting 30s for the deployed app on port 8080...'
                sleep 30
                bat 'docker ps --filter name=petclinic-app'
                bat 'curl -f http://localhost:8080/'
                echo 'Deployed: PetClinic is live on http://localhost:8080'
            }
        }
    }

    post {
        always {
            // Safety net: stop the test jar if an earlier stage failed before
            // the "Stop Test App" stage ran. Only targets TEST_PORT, never 8080.
            bat '''
                for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%TEST_PORT% ^| findstr LISTENING') do (
                    taskkill /F /PID %%a 2>nul
                )
                exit 0
            '''
            script {
                if (fileExists('target/jmeter-results.jtl')) {
                    perfReport errorFailedThreshold: 100, errorUnstableThreshold: 80, sourceDataFiles: 'target/jmeter-results.jtl'
                } else {
                    echo 'No JMeter results to report.'
                }
            }
        }
        success {
            echo 'CI/CD complete: tests passed, image built, app deployed via Docker Compose on http://localhost:8080'
        }
        failure {
            echo 'Pipeline failed - deployment not updated.'
        }
    }
}
