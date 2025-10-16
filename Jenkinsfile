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
                        echo "❌ Please install them manually on this agent."
                    fi

                    echo "👉 Checking dos2unix..."
                    if ! command -v dos2unix &>/dev/null; then
                        echo "⚠️ dos2unix not found. Install manually if required."
                    fi

                    echo "👉 Checking CMake..."
                    if ! command -v cmake &>/dev/null; then
                        echo "⚠️ cmake not found. Install manually if required."
                    fi

                    echo "👉 Checking GCC/G++..."
                    if ! command -v gcc &>/dev/null; then
                        echo "⚠️ gcc/g++ not found. Install manually if required."
                    fi

                    echo "👉 Checking CTest..."
                    if ! command -v ctest &>/dev/null; then
                        echo "⚠️ ctest not found. Install manually if required."
                    fi

                    echo "👉 Checking Sonar Scanner..."
                    if ! command -v sonar-scanner &>/dev/null; then
                        echo "⚠️ Sonar Scanner not found. Configure in Jenkins Global Tool Configuration."
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
                    # Create a Python virtual environment for cmakelint
                    python3 -m venv venv_lint
                    . venv_lint/bin/activate

                    # Install cmakelint inside the virtualenv
                    pip install --quiet cmakelint

                    # Run cmakelint if file exists
                    if [ -f src/main.c ]; then
                        cmakelint src/main.c > lint_report.txt
                        echo "✅ Lint completed. Report saved to lint_report.txt"
                    else
                        echo "❌ src/main.c not found!"
                        exit 1
                    fi

                    # Deactivate virtualenv
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
                        /opt/sonar-scanner/bin/sonar-scanner \
                        -Dsonar.organization=${SONAR_ORGANIZATION} \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.sources=. \
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
