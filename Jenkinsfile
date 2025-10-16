pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Sangamesh24/Cmake_new_practice.git'
        BRANCH = 'main'
        SONARQUBE_ENV = 'Sonar_qube_cloud'
        SONAR_ORGANIZATION = 'admin'
        SONAR_PROJECT_KEY = 'sonarqube_test'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo '🧹 Cleaning workspace...'
                cleanWs()
            }
        }

        stage('Prepare Tools') {
            steps {
                echo '🔧 Preparing required tools...'
                sh '''
                    set -e

                    # Check Python3 and pip3
                    command -v python3 >/dev/null 2>&1 || { echo "❌ python3 not found"; exit 1; }
                    command -v pip3 >/dev/null 2>&1 || { echo "❌ pip3 not found"; exit 1; }

                    # Create Python virtual environment for linting
                    python3 -m venv venv_lint
                    . venv_lint/bin/activate

                    # Upgrade pip inside venv
                    pip install --quiet --upgrade pip

                    # Install cmakelint in venv
                    pip install --quiet cmakelint || { echo "⚠️ Failed to install cmakelint"; exit 1; }

                    # Check CMake, GCC, g++, and CTest
                    command -v cmake >/dev/null || { echo "❌ cmake not found"; exit 1; }
                    command -v gcc >/dev/null || { echo "❌ gcc not found"; exit 1; }
                    command -v g++ >/dev/null || { echo "❌ g++ not found"; exit 1; }
                    command -v ctest >/dev/null || { echo "❌ ctest not found"; exit 1; }

                    echo "✅ Tools ready."
                '''
            }
        }

        stage('Checkout') {
            steps {
                echo "📥 Cloning repository ${env.GIT_REPO} on branch ${env.BRANCH}..."
                git url: env.GIT_REPO, branch: env.BRANCH, credentialsId: 'github_pat'
            }
        }

        stage('Lint') {
            steps {
                echo '🔍 Running cmakelint on src/main.c...'
                sh '''
                    . venv_lint/bin/activate
                    if [ -f src/main.c ]; then
                        cmakelint src/main.c > lint_report.txt
                        echo "✅ Lint completed. Report saved to lint_report.txt"
                    else
                        echo "❌ src/main.c not found!"
                        exit 1
                    fi
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'lint_report.txt', fingerprint: true
                }
            }
        }

        stage('Build') {
            steps {
                echo '🏗️ Running CMake build configuration and compilation...'
                sh '''
                    rm -rf build && mkdir build
                    cd build
                    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
                    make
                '''
                sh 'if [ ! -f build/compile_commands.json ]; then echo "❌ compile_commands.json missing!"; exit 1; fi'
            }
        }

        stage('Unit Tests') {
            steps {
                echo '🧪 Running unit tests...'
                sh '''
                    if [ -d build ]; then
                        cd build
                        ctest --output-on-failure
                    else
                        echo "⚠️ Build directory not found! Skipping tests."
                    fi
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '📊 Running SonarQube analysis...'
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                        sh '''
                            /opt/sonar-scanner/bin/sonar-scanner \
                                -Dsonar.organization=${SONAR_ORGANIZATION} \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=http://54.197.149.78:9000 \
                                -Dsonar.token=${SONAR_TOKEN} \
                                -Dsonar.cfamily.compile-commands=build/compile_commands.json \
                                -Dsonar.sourceEncoding=UTF-8
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo '🏁 Pipeline finished.'
        }
        success {
            echo '✅ Lint, Build, Unit Test, and SonarQube Analysis completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
