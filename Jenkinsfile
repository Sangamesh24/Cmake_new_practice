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

        stage('Clean Workspace (Start)') {
            steps {
                echo '🧹 Cleaning workspace before starting the pipeline...'
                cleanWs()
            }
        }

        stage('Prepare Tools') {
        steps {
        echo '🔧 Preparing required tools...'
        sh '''
            set -e  # Exit if any command fails

            echo "👉 Checking for Python3 and pip3..."
            if ! command -v python3 &>/dev/null || ! command -v pip3 &>/dev/null; then
                echo "⚠️ Python3 or pip3 not found."
                if [ -w /usr/bin ]; then
                    echo "Installing Python3 and pip3 (requires privileges)..."
                    yum install -y python3 python3-pip || true
                else
                    echo "❌ Cannot install Python3/pip3 — Jenkins user lacks sudo/root access."
                    echo "Please install them manually on this agent."
                fi
            fi

            echo "👉 Checking cmakelint..."
            if ! command -v cmakelint &>/dev/null; then
                echo "Installing cmakelint..."
                pip3 install --quiet cmakelint || echo "⚠️ Failed to install cmakelint"
            fi

            echo "👉 Checking dos2unix..."
            if ! command -v dos2unix &>/dev/null; then
                echo "Attempting to install dos2unix..."
                yum install -y dos2unix || echo "⚠️ Failed to install dos2unix (no permissions)"
            fi

            echo "👉 Checking CMake..."
            if ! command -v cmake &>/dev/null; then
                echo "Attempting to install cmake..."
                yum install -y epel-release || true
                yum install -y cmake || echo "⚠️ Failed to install cmake (no permissions)"
            fi

            echo "👉 Checking GCC/G++..."
            if ! command -v gcc &>/dev/null; then
                echo "Attempting to install GCC/G++..."
                yum install -y gcc gcc-c++ || echo "⚠️ Failed to install GCC/G++ (no permissions)"
            fi

            echo "👉 Checking CTest..."
            if ! command -v ctest &>/dev/null; then
                echo "Attempting to install CTest..."
                yum install -y cmake || echo "⚠️ Failed to install CTest (no permissions)"
            fi

            echo "👉 Checking Sonar Scanner..."
            if ! command -v sonar-scanner &>/dev/null; then
                echo "⚠️ Sonar Scanner not found. Please configure it under Jenkins Global Tool Configuration."
            fi

            echo "✅ Tool preparation completed."
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
                echo '🔍 Running lint checks on src/main.c...'
                sh '''
                    if [ -f src/main.c ]; then
                        cmakelint src/main.c > lint_report.txt
                    else
                        echo "❌ src/main.c not found!"
                        exit 1
                    fi
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
                echo '🏗️  Running CMake build configuration and compilation...'
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
                        echo "⚠️  Build directory not found! Skipping tests."
                        exit 1
                    fi
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '📊 Running SonarQube (SonarCloud) analysis...'
                withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                    sh '''
                        sonar-scanner \
                        -Dsonar.organization=${SONAR_ORGANIZATION} \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.sources=src \
                        -Dsonar.cfamily.compile-commands=build/compile_commands.json \
                        -Dsonar.sourceEncoding=UTF-8
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '🏁 Pipeline finished.'
        }
        success {
            echo '✅ Lint, Build, Unit Test, SonarQube Analysis, and Cleanup completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
