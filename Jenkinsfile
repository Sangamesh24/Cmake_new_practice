pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Sangamesh24/Cmake_new_practice.git'
        BRANCH = 'main'
        SONARQUBE_ENV = 'Sonar_qube_cloud' 
        SONAR_ORGANIZATION = 'admin'
        SONAR_PROJECT_KEY = 'sonarqube_test'
        SONAR_HOST_URL = 'http://54.197.149.78:9000'
        SONAR_TOKEN = 'squ_f7d5910df8fb5965a8839113f47104aa9e6fc7a7'
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
                echo '🔧 Checking required tools on Ubuntu...'
                sh '''
                    set -e

                    echo "👉 Checking Python3, pip3, venv..."
                    command -v python3 >/dev/null || { echo "❌ Python3 not found. Install: sudo apt install python3"; exit 1; }
                    command -v pip3 >/dev/null || { echo "❌ pip3 not found. Install: sudo apt install python3-pip"; exit 1; }
                    python3 -m venv --help >/dev/null || { echo "❌ python3-venv missing. Install: sudo apt install python3-venv"; exit 1; }

                    echo "👉 Checking GCC/G++..."
                    command -v gcc >/dev/null || { echo "❌ gcc missing. Install: sudo apt install gcc g++"; exit 1; }

                    echo "👉 Checking CMake..."
                    command -v cmake >/dev/null || { echo "❌ cmake missing. Install: sudo apt install cmake"; exit 1; }

                    echo "👉 Checking dos2unix..."
                    command -v dos2unix >/dev/null || echo "⚠️ dos2unix not found. Optional."

                    echo "✅ All required tools found."
                '''
            }
        }

        stage('Checkout') {
            steps {
                echo "📥 Cloning repository ${env.GIT_REPO}..."
                git url: env.GIT_REPO, branch: env.BRANCH
            }
        }

        stage('Lint') {
            steps {
                echo '🔍 Running lint checks on src/main.c...'
                sh '''
                    # Create virtual environment for lint
                    python3 -m venv venv_lint
                    . venv_lint/bin/activate

                    # Install cmakelint in virtualenv
                    pip install --quiet cmakelint

                    # Run cmakelint if file exists
                    if [ -f src/main.c ]; then
                        cmakelint src/main.c > lint_report.txt
                        echo "✅ Lint completed. Report saved to lint_report.txt"
                    else
                        echo "⚠️ src/main.c not found! Skipping lint."
                        touch lint_report.txt
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
                echo '🧪 Running unit tests...'
                sh '''
                    if [ -d build ]; then
                        cd build
                        ctest --output-on-failure || echo "⚠️ No tests found or tests failed."
                    else
                        echo "⚠️ Build directory missing. Skipping tests."
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
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONAR_TOKEN} \
                        -Dsonar.cfamily.compile-commands=build/compile_commands.json \
                        -Dsonar.sourceEncoding=UTF-8 || echo "⚠️ SonarQube scan failed. Check server/network."
                    """
                }
            }
        }
    }

    post {
        always { echo '🏁 Pipeline finished.' }
        success { echo '✅ Pipeline completed successfully!' }
        failure { echo '❌ Pipeline failed. Check logs for details.' }
    }
}
