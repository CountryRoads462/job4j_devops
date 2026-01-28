pipeline {
    agent { label 'agent-jdk21' }

    tools {
        git 'Default'
    }

    options {
        timestamps()
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Environment') {
            steps {
                sh 'chmod +x ./gradlew'
            }
        }

        stage('Check + JaCoCo (Parallel)') {
            parallel {

                stage('Check') {
                    steps {
                        script {
                            try {
                                sh './gradlew check'
                            } catch (err) {
                                unstable('Tests failed')
                            }
                        }
                    }
                }

                stage('JaCoCo Report') {
                    steps {
                        script {
                            try {
                                sh './gradlew jacocoTestReport'
                            } catch (err) {
                                unstable('JaCoCo report generation failed')
                            }
                        }
                    }
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    try {
                        sh './gradlew build -x test'
                    } catch (err) {
                        error('Packaging failed')
                    }
                }
            }
        }

        stage('JaCoCo Verification') {
            steps {
                script {
                    try {
                        sh './gradlew jacocoTestCoverageVerification'
                    } catch (err) {
                        unstable('Coverage thresholds not met')
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t job4j_devops:${BUILD_NUMBER} .
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
