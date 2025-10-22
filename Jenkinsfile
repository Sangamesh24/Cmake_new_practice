pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Sangamesh24/Cmake_new_practice.git'
        BRANCH = 'main'
        SONARQUBE_ENV = 'Sonar_qube_cloud'
        SONAR_ORGANIZATION = 'Sangamesh24_Cmake_new_practice'
        SONAR_PROJECT_KEY = 'Cmake_new_practice'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo 'Cleaning workspace...'
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                echo "📥 Cloning repository ${env.GIT_REPO} on branch ${env.BRANCH}..."
                git url: env.GIT_REPO, branch: env.BRANCH, credentialsId: 'github_pat'
            }
        }

        stage('Prepare Tools & Lint Environment') {
            steps {
                echo '🔧 Preparing tools and Python virtual environment...'
                sh '''
                    set -e
                    command -v python3 >/dev/null 2>&1 || { echo " python3 not found"; exit 1; }
                    command -v pip3 >/dev/null 2>&1 || { echo " pip3 not found"; exit 1; }

                    if [ ! -d venv_lint ]; then
                        python3 -m venv venv_lint
                    fi

                    . venv_lint/bin/activate
                    pip install --quiet --upgrade pip
                    pip install --quiet cmakelint || { echo " Failed to install cmakelint"; exit 1; }

                    command -v cmake >/dev/null || { echo " cmake not found"; exit 1; }
                    command -v gcc >/dev/null || { echo " gcc not found"; exit 1; }
                    command -v g++ >/dev/null || { echo " g++ not found"; exit 1; }
                    command -v ctest >/dev/null || { echo " ctest not found"; exit 1; }

                    echo " Tools and lint environment ready."
                '''
            }
        }

        stage('Lint') {
            steps {
                echo '🔍 Running cmakelint on src/main.c...'
                sh '''
                    if [ ! -d venv_lint ]; then
                        echo " venv_lint not found! Prepare Tools stage failed."
                        exit 1
                    fi

                    . venv_lint/bin/activate

                    if [ -f src/main.c ]; then
                        cmakelint src/main.c > lint_report.txt
                        echo " Lint completed. Report saved to lint_report.txt"
                    else
                        echo " src/main.c not found!"
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
                echo ' Running CMake build configuration and compilation...'
                sh '''
                    rm -rf build && mkdir build
                    cd build
                    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
                    make
                '''
                sh 'if [ ! -f build/compile_commands.json ]; then echo " compile_commands.json missing!"; exit 1; fi'
            }
        }

        stage('Unit Tests') {
            steps {
                echo ' Running unit tests...'
                sh '''
                    if [ -d build ]; then
                        cd build
                        ctest --output-on-failure
                    else
                        echo " Build directory not found! Skipping tests."
                    fi
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo " Running SonarQube analysis..."
                withCredentials([string(credentialsId: 'Sonarqube_configuration_jenkins', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('Sonar_qube_cloud') {
                        sh '''
                            echo " Checking compile_commands.json existence..."
                            ls -l build/compile_commands.json || { echo " compile_commands.json not found!"; exit 1; }

                            echo " Starting sonar-scanner with extended timeout and memory..."
                            export SONAR_SCANNER_OPTS="-Xmx2048m -Dhttp.timeout=600000"
                            /opt/sonar-scanner/bin/sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=. \
                                -Dsonar.cfamily.compile-commands=build/compile_commands.json \
                                -Dsonar.exclusions=**/venv_lint/**,**/.scannerwork/**,**/tests/**,**/*.log \
                                -Dsonar.host.url=https://sonarcloud.io \
                                -Dsonar.token=${SONAR_TOKEN} \
                                -Dsonar.sourceEncoding=UTF-8 \
                                -Dsonar.ws.timeout=600 \
                                -Dsonar.cfamily.cache.enabled=false \
                                -Dsonar.scanner.skipSystemTruststore=true \
                                -X
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
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
