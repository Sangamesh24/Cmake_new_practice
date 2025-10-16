pipeline {
    agent { label 'linuxgit' }
    environment {
        GIT_REPO = 'https://github.com/Dinesh-SMG/BuildFlow.git'
        BRANCH = 'main'
        // SonarCloud Configuration (Updated organization key to lowercase for consistency with logs)
        SONARQUBE_ENV = 'SonarCloud' 
        SONAR_ORGANIZATION = 'dinesh-smg' // <-- Updated to lowercase to match successful log key
        SONAR_PROJECT_KEY = 'Dinesh-SMG_BuildFlow'
    }
    stages {
        stage('Prepare Tools') {
            steps {
                echo 'Installing required tools...'
                sh '''
                    # Update and install Python3/pip3 if missing
                    if ! command -v pip3 &>/dev/null; then
                        sudo yum install -y python3 python3-pip || true
                    fi
                    # Install cmakelint
                    pip3 install --quiet cmakelint
                    # Install dos2unix
                    if ! command -v dos2unix &>/dev/null; then
                        sudo yum install -y dos2unix || true
                    fi
                    # Install cmake
                    if ! command -v cmake &>/dev/null; then
                        sudo yum install -y epel-release || true
                        sudo yum install -y cmake || true
                    fi
                    
                    # Install GCC/G++ compilers for C/C++ build
                    if ! command -v gcc &>/dev/null; then
                        sudo yum install -y gcc gcc-c++ || true
                    fi
                    # Install CTest (usually part of CMake, but good to ensure)
                    if ! command -v ctest &>/dev/null; then
                        sudo yum install -y cmake || true
                    fi
                    # Install Sonar-Scanner (requires tool configuration in Jenkins)
                    if ! command -v sonar-scanner &>/dev/null; then
                        echo "WARNING: Sonar Scanner command not found. Ensure it's configured in Jenkins Global Tool Configuration."
                    fi
                '''
            }
        }
        stage('Checkout') {
            steps {
                echo "Cloning repository ${env.GIT_REPO} on branch ${env.BRANCH}..."
                // Using the git step to explicitly clone the repository
                git url: env.GIT_REPO, branch: env.BRANCH
            }
        }
        stage('Lint') {
            steps {
                echo 'Running lint checks on main.c...'
                sh '''
                    if [ -f src/main.c ]; then
                        cmakelint main.c > lint_report.txt
                        # Fail build if lint errors found (uncomment if strict)
                        # grep -q "Total Errors: [1-9]" lint_report.txt && exit 1 || true
                    else
                        echo "main.c not found!"
                        exit 1
                    fi
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'lint_report.txt', fingerprint: true
                    fingerprint 'main.c'
                }
            }
        }
        stage('Build') {
            steps {
                echo 'Running CMake build configuration and compilation...'
                // Clear and create build directory
                sh 'rm -rf build && mkdir build' 
                
                // Configure CMake and explicitly generate compile_commands.json
                sh '''
                    cd build
                    # This flag is CRUCIAL for SonarQube C/C++ analysis
                    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
                    
                    # Compile the project
                    make
                '''
                
                // Verification step
                sh 'if [ ! -f build/compile_commands.json ]; then echo "ERROR: compile_commands.json was not generated!"; exit 1; fi'
            }
        }
        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh '''
                    if [ -d build ]; then
                        cd build
                        # Run all registered CTest tests
                        ctest --output-on-failure
                    else
                        echo "Build directory not found! Skipping tests."
                        exit 1
                    fi
                '''
            }
        }
        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube (SonarCloud) analysis...'
                withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                    sh '''
                        sonar-scanner \\
                        -Dsonar.organization=${SONAR_ORGANIZATION} \\
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \\
                        -Dsonar.sources=src \\
                        -Dsonar.cfamily.compile-commands=build/compile_commands.json \\
                        -Dsonar.sourceEncoding=UTF-8
                    '''
                }
            }
        }
        stage('Clean') {
            steps {
                echo 'Cleaning up build artifacts...'
                sh 'rm -rf build lint_report.txt'
            }
        }
    }
    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Lint, Build, UnitTest, SonarQubeAnalysis and Clean completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
