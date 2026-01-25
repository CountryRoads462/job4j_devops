pipeline {
    agent { label 'agent-jdk21' }

    tools {
        git 'Default'
    }

    stages {
        stage('Prepare Environment') {
            steps {
                sh 'chmod +x ./gradlew'
            }
        }

        stage('Check + JaCoCo Report (Parallel)') {
            parallel {
                stage('Check') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh './gradlew check'
                        }
                    }
                }

                stage('JaCoCo Report') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh './gradlew jacocoTestReport'
                        }
                    }
                }
            }
        }

        stage('Package') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh './gradlew build'
                }
            }
        }

        stage('JaCoCo Verification') {
            steps {
                sh './gradlew jacocoTestCoverageVerification'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                  whoami
                  id
                  docker ps
                  docker build -t job4j_devops .
                '''
            }
        }
    }

    post {
        always {
            script {
                def buildInfo = """
                    Build number: ${currentBuild.number}
                    Build status: ${currentBuild.currentResult}
                    Started at: ${new Date(currentBuild.startTimeInMillis)}
                    Duration: ${currentBuild.durationString}
                """
                telegramSend(message: buildInfo)
            }
        }
    }
}
