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
                    // 1. Start Spring Boot in the background (Windows style)
                    bat 'start /B java -jar target/spring-petclinic-4.0.0-SNAPSHOT.jar --server.port=8081'
                    
                    // 2. Give the application a few seconds to fully boot up before Cypress runs
                    bat 'timeout /t 20 /nobreak'
                    
                    // 3. Install dependencies and run Cypress
                    bat 'npm install'
                    bat 'npx cypress run --config baseUrl=http://localhost:8081'
                    
                    // 4. Clean up: Kill the Java process running on port 8081 after tests complete
                    bat 'for /f "tokens=5" %a in (\'netstat -aon ^| findstr 8081\') do taskkill /F /PID %a'
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