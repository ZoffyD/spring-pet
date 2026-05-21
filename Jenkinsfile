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
                // Copy the built jar to a fixed name, then launch it in the
                // background. JENKINS_NODE_COOKIE=dontKillMe stops Jenkins from
                // reaping the process when this shell exits; output -> target\app-test.log.
                bat '''
                    for %%f in (target\\*.jar) do copy /Y "%%f" target\\app-test.jar >nul
                    set "PATH=%JAVA_HOME%\\bin;%PATH%"
                    set JENKINS_NODE_COOKIE=dontKillMe
                    start "" /B cmd /c "java -Dserver.port=%TEST_PORT% -Dspring.autoconfigure.exclude=org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration -jar target\\app-test.jar > target\\app-test.log 2>&1"
                '''
                // Poll the port until the app answers (up to ~2 min) instead of a
                // blind sleep; fail with the app log if it never comes up.
                bat '''
                    for /L %%i in (1,1,40) do (
                        curl -s -o nul http://localhost:%TEST_PORT%/ && exit /b 0
                        echo Waiting for app on port %TEST_PORT%... (%%i/40)
                        ping -n 4 127.0.0.1 >nul
                    )
                    echo ERROR: app did not start on port %TEST_PORT%. Last 80 log lines:
                    powershell -Command "if (Test-Path 'target\\app-test.log') { Get-Content 'target\\app-test.log' -Tail 80 }"
                    exit /b 1
                '''
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
