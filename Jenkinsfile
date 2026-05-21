pipeline {
    agent any
    stages {
        stage('Source Code Management') {
            steps { 
                checkout scm 
            }
        }
        
        stage('Build & Compile') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'mvn clean package -DskipTests'
                    } else {
                        bat 'mvn clean package -DskipTests'
                    }
                }
            }
        }
        
        stage('E2E Testing (Cypress)') {
            steps {
                script {
                    // 1. Kill anything left on 8081 from a previous build, then start Spring Boot in the background
                    bat 'powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }; exit 0"'
                    bat 'start /B java -jar target/spring-petclinic-4.0.0-SNAPSHOT.jar --server.port=8081'
                    
                    // 2. Wait until the app actually responds on 8081 (Jenkins 'bat' cannot use the 'timeout' command)
                    bat 'powershell -NoProfile -Command "for ($i=0; $i -lt 60; $i++) { try { Invoke-WebRequest -UseBasicParsing http://localhost:8081/actuator/health -TimeoutSec 3 | Out-Null; Write-Host \'App is up on 8081\'; exit 0 } catch { Start-Sleep -Seconds 2 } }; Write-Host \'App did not start on 8081 within 120s\'; exit 1"'
                    
                    // 3. Install dependencies and run Cypress
                    bat 'npm install'
                    bat 'npx cypress run --config baseUrl=http://localhost:8081'
                    
                    // 4. Clean up: stop the Java process running on port 8081 after tests complete
                    bat 'powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }; exit 0"'
                }
            }
        }
        
        stage('Performance Testing (JMeter)') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            for file in src/test/jmeter/*.jmx; do
                                jmeter -n -t "$file" -l "target/jmeter-results.jtl"
                            done
                        '''
                    } else {
                        bat '''
                            IF NOT EXIST target MD target
                            for %%f in (src\\test\\jmeter\\*.jmx) do (
                                jmeter -n -t "%%f" -l "target\\jmeter-results.jtl"
                            )
                        '''
                    }
                }
            }
        }

        stage('Deploy (Local Docker Compose)') {
            steps {
                echo 'Deploying integrated services matrix to local Docker Engine...'
                script {
                    if (isUnix()) {
                        sh 'docker-compose down || true'
                        sh 'docker-compose up -d --build'
                    } else {
                        bat 'docker-compose down || rem'
                        bat 'docker-compose up -d --build'
                    }
                }
                echo 'Application is live and containerized at http://localhost:8081'
            }
        }
    }
    
    post {
        always {
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
            perfReport errorFailedThreshold: 100, errorUnstableThreshold: 80, sourceDataFiles: 'target/jmeter-results.jtl'
            
            script {
                if (fileExists('cypress/reports')) {
                    publishHTML(target: [reportDir: 'cypress/reports', reportFiles: 'index.html', reportName: 'Cypress E2E Report'])
                } else {
                    echo "Skipping HTML report generation: cypress/reports folder missing."
                }
            }
        }
    }
}