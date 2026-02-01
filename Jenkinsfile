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
                                sh './gradlew check -P"dotenv.filename"="/var/agent-jdk21/env/.env.develop"'
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
                                sh './gradlew jacocoTestReport -P"dotenv.filename"="/var/agent-jdk21/env/.env.develop"'
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
                        sh './gradlew build -x test -P"dotenv.filename"="/var/agent-jdk21/env/.env.develop"'
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
                        sh './gradlew jacocoTestCoverageVerification -P"dotenv.filename"="/var/agent-jdk21/env/.env.develop"'
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

        stage('Update DB') {
            steps {
                script {
                    sh './gradlew update -P"dotenv.filename"="/var/agent-jdk21/env/.env.develop"'
                }
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
