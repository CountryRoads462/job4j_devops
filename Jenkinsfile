pipeline {
    agent { label 'agent-jdk21' }

    tools {
        git 'Default'
    }

    options {
        timestamps()
        ansiColor('xterm')
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
                                unstable('Unit / integration tests failed')
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
                        error('Packaging failed – this is a real failure')
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
                def emoji = currentBuild.currentResult == 'SUCCESS'  ? '🟢' :
                            currentBuild.currentResult == 'UNSTABLE' ? '🟡' :
                            '🔴'

                def message = """
${emoji} *Build ${currentBuild.currentResult}*

• Job: ${env.JOB_NAME}
• Build: #${currentBuild.number}
• Started: ${new Date(currentBuild.startTimeInMillis)}
• Duration: ${currentBuild.durationString}
• URL: ${env.BUILD_URL}
"""
                telegramSend(message: message)
            }
        }
    }
}
