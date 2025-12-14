pipeline {
    agent { label 'agent2' }

    tools {
        git 'Default'
    }

    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    sh 'chmod +x ./gradlew'
                }
            }
        }
        stage('Build') {
            parallel {
                stage('Checkstyle Main') {
                    steps {
                        script {
                            sh './gradlew checkstyleMain'
                        }
                    }
                }
                stage('Checkstyle Test') {
                    steps {
                        script {
                            sh './gradlew checkstyleTest'
                        }
                    }
                }
                stage('Build') {
                    steps {
                        script {
                            sh './gradlew compileJava'
                        }
                    }
                }
                stage('Test') {
                    steps {
                        script {
                            sh './gradlew test'
                            sh './gradlew jacocoTestReport'
                            sh './gradlew jacocoTestCoverageVerification'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                def buildInfo = "Build number: ${currentBuild.number}\n" +
                                "Build status: ${currentBuild.currentResult}\n" +
                                "Started at: ${new Date(currentBuild.startTimeInMillis)}\n" +
                                "Duration so far: ${currentBuild.durationString}"
                telegramSend(message: buildInfo)
            }
        }
    }
}
