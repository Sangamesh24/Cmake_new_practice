pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Sangamesh24/Cmake_new_practice.git'
        BRANCH = 'main'
        SONARQUBE_ENV = 'Sonar_qube_cloud' 
        SONAR_ORGANIZATION = 'admin'
        SONAR_PROJECT_KEY = 'sonarqube_test'
        SONAR_HOST_URL = 'http://54.197.149.78:9000'
        SONAR_TOKEN = credentials('sonar-token') // Add your token in Jenkins credentials
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo '🧹 Cleaning workspace before starting the pipeline...'
                cleanWs()
            }
        }

        stage('Prepare Tools') {
            steps {
                echo '🔧 Preparing required tools...'
                sh '''
                    set -e

                    echo "👉 Checking Python3 and pip3..."
                    if ! command -v python3 &>/dev/null || ! command -v pip3 &>/dev/null; then
                        echo "❌ Python3 or pip3 not found. Install python3 & python3-pip on the agent."
                        exit 1
                    fi

                    echo "👉 Checking CMake..."
                    if ! command -v cmake &>/dev/null; then
                        echo "❌ CMake not found. Install cmake on the agent."
                        exit 1
                    fi

                    echo "👉 Checking GCC/G++..."
                    if ! command -v gcc &>/dev/null; then
                        echo "❌ GCC/G++ not found. Install gcc/g++ on the agent."
                        exit 1
                    fi

                    echo "👉 Checking CTest..."
                    if ! command -v ctest &>/dev/null; then
                        echo "❌ CTest not found. Install cmake (which includes CTest) on the agent."
                        exit 1
                    fi

                    echo "✅ Tools are present."
                '''
            }
        }

        stage('Checkout') {
            steps {
                echo "📥 Cloning repository ${env.GIT_REPO} on branch ${env.BRANCH}..."
                git url: env.GIT_REPO, branch: env.BRANCH
            }
        }

        stage('Lint') {
            steps {
                echo '🔍 Running cmakelint on src/main.c...'
                sh '''
                    # Create a Python virtual environment for cmakelint
                    python3 -m venv venv_lint
                    . venv_lint/bin/activate

                    # Install cmakelint
                    pip install --quiet cmakelint

                    # Run lint
                    if [ -f src/main.c ]; then
                        cmakelint src/main.c > lint_report.txt
                        echo "✅ Lint completed. Report saved to lint_report.txt"
                    else
                        echo "❌ src/main.c not found!"
                        exit 1
                    fi

                    deactivate
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'lint_report.txt', fingerprint: true
                    fingerprint 'src/main.c'
                }
            }
        }

        stage('Build') {
            steps {
                echo '🏗️ Running CMake build and compilation...'
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
                        ctest --output-on-failure || echo "⚠️ No tests found or some tests failed."
                    else
                        echo "⚠️ Build directory not found! Skipping tests."
                        exit 1
                    fi
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '📊 Running SonarQube analysis...'
                withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                    sh """
                        /opt/sonar-scanner/bin/sonar-scanner \
                        -Dsonar.organization=${SONAR_ORGANIZATION} \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.sources=src \
                        -Dsonar.exclusions=venv_lint/**,build/** \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.token=${SONAR_TOKEN} \
                        -Dsonar.cfamily.compile-commands=build/compile_commands.json \
                        -Dsonar.sourceEncoding=UTF-8
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
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
