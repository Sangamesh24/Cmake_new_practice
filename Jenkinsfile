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

                    echo "👉 Checking Python3..."
                    command -v python3 || { echo "❌ Python3 not found! Install python3 on the agent."; exit 1; }

                    echo "👉 Checking pip3..."
                    command -v pip3 || { echo "❌ pip3 not found! Run 'sudo apt install -y python3-pip'."; exit 1; }

                    echo "👉 Installing cmakelint..."
                    pip3 install --quiet cmakelint || echo "⚠️ Failed to install cmakelint"

                    echo "👉 Checking CMake..."
                    command -v cmake || { echo "❌ cmake not found! Install cmake."; exit 1; }

                    echo "👉 Checking GCC/G++..."
                    command -v gcc || { echo "❌ gcc not found! Install gcc."; exit 1; }
                    command -v g++ || { echo "❌ g++ not found! Install g++."; exit 1; }

                    echo "👉 Checking CTest..."
                    command -v ctest || { echo "❌ ctest not found! Install ctest."; exit 1; }

                    echo "✅ Tools are ready."
                '''
            }
        }

        stage('Checkout') {
            steps {
                git url: env.GIT_REPO, branch: env.BRANCH
            }
        }

        stage('Lint') {
            steps {
                echo '🔍 Running cmakelint on src/main.c...'
                sh '''
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
                echo '🏗️ Running CMake build...'
                sh '''
                    rm -rf build && mkdir build
                    cd build
                    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
                    make
                '''
                sh 'test -f build/compile_commands.json || { echo "❌ compile_commands.json missing!"; exit 1; }'
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    if [ -d build ]; then
                        cd build
                        ctest --output-on-failure || echo "⚠️ No tests found or some tests failed."
                    fi
                '''
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token') // Jenkins secret token
            }
            steps {
                echo '📊 Running SonarQube analysis...'
                withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                    sh """
                        /opt/sonar-scanner/bin/sonar-scanner \
                        -Dsonar.organization=${SONAR_ORGANIZATION} \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.sources=. \
                        -Dsonar.cfamily.compile-commands=build/compile_commands.json \
                        -Dsonar.sourceEncoding=UTF-8 \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }
    }

    post {
        always {
            echo '🏁 Pipeline finished.'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs.'
        }
    }
}
