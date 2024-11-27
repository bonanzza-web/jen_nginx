pipeline {
    agent any

    stages {
        stage('Test stage') {
            steps {
                sh 'echo "Test complited"'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '/var/jenkins_home/tools/hudson.plugins.sonar.SonarRunnerInstallation/sonarscanner/bin/bin/sonar-scanner -Dsonar.projectKey=jen_nginx -Dsonar.host.url=http://192.168.0.7:9000'
                }
            }
        }
        stage('Sonar Quality Gates') {
            steps {
                timeout(time: 3, unit: 'MINUTES') { 
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('Nexus login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWD')]) {
                    sh 'docker login https://nexus.encaso.ru:8084 -u $NEXUS_USER -p $NEXUS_PASSWD'
                }
            }
        }
    }
}