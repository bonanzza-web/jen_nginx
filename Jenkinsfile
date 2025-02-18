pipeline {
    agent any
    environment {
        REGISTRY = "nexus.encaso.ru"
        IMAGE_NAME = "nginx-dev"
    }
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
                    sh "docker login https://${env.REGISTRY} -u $NEXUS_USER -p $NEXUS_PASSWD"
                }
            }
        }
        stage('Build image') {
            steps {
                script {
                    sh "docker build . -t ${env.REGISTRY}/${env.IMAGE_NAME}:latest"
                }
            }
        }
        stage('Push image') {
            steps {
                sh "docker push ${env.REGISTRY}/${env.IMAGE_NAME}:latest"
            }
        }
		stage('Set permissions docker.sock') {
			steps {
				sh "ansible-playbook -i ./ansible/inventory/hosts.txt ./ansible/playbook.yml"
			}
		}
		
        stage('Deploy app') {
            steps {
                withCredentials([
                    string(credentialsId: 'REMOTE_DOCKER_HOST', variable: 'REMOTE_DOCKER_HOST'),
                    string(credentialsId: 'REMOTE_DOCKER_PORT', variable: 'REMOTE_DOCKER_PORT')
                ]){
                    sshagent(credentials: ['docker-server']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no quehoras@$REMOTE_DOCKER_HOST -p $REMOTE_DOCKER_PORT < ./docker/cmd.txt
                    """
                }
                }
                
            }
        }
    }
}