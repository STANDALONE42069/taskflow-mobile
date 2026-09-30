pipeline {
    agent {
        kubernetes {
            cloud 'kubernetes'
            defaultContainer 'flutter'
            yamlFile 'ci/kubernetes-agent.yaml'
            retries 2
        }
    }

    options {
        timeout(time: 90, unit: 'MINUTES')
        disableConcurrentBuilds(abortPrevious: false)
        buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
    }

    environment {
        CI = 'true'
        PUB_CACHE = "${env.WORKSPACE}/.pub-cache"
    }

    stages {
        stage('Dependencies') {
            steps {
                sh 'flutter --version'
                sh 'flutter pub get --enforce-lockfile'
            }
        }

        stage('Parallel Quality Gates') {
            parallel {
                stage('Flutter Analyze') {
                    steps {
                        sh 'flutter analyze --no-pub --no-fatal-infos'
                    }
                }

                stage('Flutter Tests') {
                    steps {
                        sh 'flutter test --no-pub --coverage'
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'coverage/lcov.info', allowEmptyArchive: true
                        }
                    }
                }

                stage('SCA — OSV Scanner') {
                    steps {
                        container('osv-scanner') {
                            sh 'osv-scanner scan source --recursive --format json --output osv-scanner.json .'
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'osv-scanner.json', allowEmptyArchive: true
                        }
                    }
                }
            }
        }

        stage('Build Debug APK') {
            steps {
                sh 'flutter build apk --debug --no-pub --build-number="$BUILD_NUMBER"'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk', fingerprint: true
                }
            }
        }

        stage('Build Signed Release AAB') {
            when {
                beforeAgent true
                branch 'main'
            }
            steps {
                withCredentials([
                    file(credentialsId: 'taskflow-mobile-android-keystore', variable: 'ANDROID_KEYSTORE_FILE'),
                    string(credentialsId: 'taskflow-mobile-android-store-password', variable: 'ANDROID_STORE_PASSWORD'),
                    usernamePassword(
                        credentialsId: 'taskflow-mobile-android-signing-key',
                        usernameVariable: 'ANDROID_KEY_ALIAS',
                        passwordVariable: 'ANDROID_KEY_PASSWORD'
                    )
                ]) {
                    sh '''
                        set +x
                        test -s "$ANDROID_KEYSTORE_FILE"
                        keytool -list -keystore "$ANDROID_KEYSTORE_FILE" \
                            -storepass "$ANDROID_STORE_PASSWORD" -alias "$ANDROID_KEY_ALIAS" >/dev/null
                        (cd android && ./gradlew --stop)
                        flutter build appbundle --release --no-pub --build-number="$BUILD_NUMBER"
                    '''
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'build/app/outputs/bundle/release/*.aab', fingerprint: true
                }
            }
        }
    }

    post {
        success {
            script {
                def message = "✅ ${env.JOB_NAME} #${env.BUILD_NUMBER} (${env.BRANCH_NAME}) passed: ${env.BUILD_URL}"
                if (env.TASKFLOW_SLACK_CHANNEL?.trim()) {
                    try { slackSend(channel: env.TASKFLOW_SLACK_CHANNEL, color: 'good', message: message) }
                    catch (Exception error) { echo "Slack notification was unavailable: ${error.message}" }
                }
                if (env.TASKFLOW_CI_EMAIL_RECIPIENTS?.trim()) {
                    try { emailext(to: env.TASKFLOW_CI_EMAIL_RECIPIENTS, subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}", body: message) }
                    catch (Exception error) { echo "Email notification was unavailable: ${error.message}" }
                }
            }
        }
        failure {
            script {
                def message = "❌ ${env.JOB_NAME} #${env.BUILD_NUMBER} (${env.BRANCH_NAME}) failed: ${env.BUILD_URL}"
                if (env.TASKFLOW_SLACK_CHANNEL?.trim()) {
                    try { slackSend(channel: env.TASKFLOW_SLACK_CHANNEL, color: 'danger', message: message) }
                    catch (Exception error) { echo "Slack notification was unavailable: ${error.message}" }
                }
                if (env.TASKFLOW_CI_EMAIL_RECIPIENTS?.trim()) {
                    try { emailext(to: env.TASKFLOW_CI_EMAIL_RECIPIENTS, subject: "FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}", body: message) }
                    catch (Exception error) { echo "Email notification was unavailable: ${error.message}" }
                }
            }
        }
        always {
            archiveArtifacts artifacts: 'osv-scanner.json,coverage/lcov.info,build/app/outputs/flutter-apk/*.apk,build/app/outputs/bundle/release/*.aab', allowEmptyArchive: true, fingerprint: true
        }
    }
}
