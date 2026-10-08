pipeline {
    agent any

    parameters {
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip running unit tests')
        booleanParam(name: 'PUSH_IMAGES', defaultValue: false, description: 'Push built Docker images to Docker Hub')
        stringParam(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
        booleanParam(name: 'DEPLOY_K8S', defaultValue: false, description: 'Deploy Helm chart to Kubernetes cluster')
        stringParam(name: 'K8S_NAMESPACE', defaultValue: 'wonderlust', description: 'Kubernetes target namespace')
        stringParam(name: 'HELM_RELEASE', defaultValue: 'wonderlust', description: 'Helm release name')
    }

    environment {
        DOCKER_HUB_USER       = 'mukeshchaudhary14'
        BACKEND_IMAGE         = "${DOCKER_HUB_USER}/wonderlust-backend:${params.IMAGE_TAG}"
        FRONTEND_IMAGE        = "${DOCKER_HUB_USER}/wonderlust-frontend:${params.IMAGE_TAG}"
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        TRIVY_CACHE_DIR       = "${WORKSPACE}/.cache/trivy"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo "🚀 Checking out branch: ${env.BRANCH_NAME ?: 'main'}"
                checkout scm
            }
        }

        stage('Security Scan - Source (Trivy FS)') {
            steps {
                echo '🛡️ Running Trivy File System & Dependency Vulnerability Scan...'
                sh '''
                    mkdir -p trivy-reports "${TRIVY_CACHE_DIR}"
                    if command -v trivy >/dev/null 2>&1; then
                        trivy fs --severity HIGH,CRITICAL --ignore-unfixed --format table -o trivy-reports/fs-report.txt . || true
                    else
                        docker run --rm \
                            -v "${WORKSPACE}:/workspace" \
                            -v "${TRIVY_CACHE_DIR}:/root/.cache/trivy" \
                            aquasec/trivy:latest fs --severity HIGH,CRITICAL --ignore-unfixed --format table -o /workspace/trivy-reports/fs-report.txt /workspace || true
                    fi
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                echo "🐳 Building Docker images with tag: ${params.IMAGE_TAG}..."
                sh '''
                    docker build -t "${BACKEND_IMAGE}" -f backend/Dockerfile ./backend
                    docker build -t "${FRONTEND_IMAGE}" -f frontend/Dockerfile ./frontend
                '''
            }
        }

        stage('Security Scan - Images (Trivy Image)') {
            steps {
                echo '🛡️ Running Trivy Container Image Scan...'
                sh '''
                    mkdir -p trivy-reports
                    if command -v trivy >/dev/null 2>&1; then
                        trivy image --severity HIGH,CRITICAL --ignore-unfixed --format table -o trivy-reports/backend-image-report.txt "${BACKEND_IMAGE}" || true
                        trivy image --severity HIGH,CRITICAL --ignore-unfixed --format table -o trivy-reports/frontend-image-report.txt "${FRONTEND_IMAGE}" || true
                    else
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            -v "${WORKSPACE}:/workspace" \
                            -v "${TRIVY_CACHE_DIR}:/root/.cache/trivy" \
                            aquasec/trivy:latest image --severity HIGH,CRITICAL --ignore-unfixed --format table -o /workspace/trivy-reports/backend-image-report.txt "${BACKEND_IMAGE}" || true
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            -v "${WORKSPACE}:/workspace" \
                            -v "${TRIVY_CACHE_DIR}:/root/.cache/trivy" \
                            aquasec/trivy:latest image --severity HIGH,CRITICAL --ignore-unfixed --format table -o /workspace/trivy-reports/frontend-image-report.txt "${FRONTEND_IMAGE}" || true
                    fi
                '''
            }
        }

        stage('Push Images to Docker Hub') {
            when {
                expression { return params.PUSH_IMAGES }
            }
            steps {
                echo '📤 Authenticating and pushing images to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push "${BACKEND_IMAGE}"
                        docker push "${FRONTEND_IMAGE}"
                        docker logout
                    '''
                }
            }
        }

        stage('Validate Helm Chart & IaC') {
            steps {
                echo '☸️ Validating Helm Chart and Kubernetes Manifests...'
                sh '''
                    if command -v helm >/dev/null 2>&1; then
                        helm lint helm/wonderlust
                        helm template "${HELM_RELEASE}" helm/wonderlust --namespace "${K8S_NAMESPACE}" > /dev/null
                        echo "✅ Helm chart validation successful!"
                    else
                        echo "⚠️ Helm not found on agent, skipping helm lint."
                    fi
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression { return params.DEPLOY_K8S }
            }
            steps {
                echo "🚀 Deploying release '${params.HELM_RELEASE}' to namespace '${params.K8S_NAMESPACE}'..."
                sh '''
                    kubectl create namespace "${K8S_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
                    helm upgrade --install "${HELM_RELEASE}" helm/wonderlust \
                        --namespace "${K8S_NAMESPACE}" \
                        --set backend.image.tag="${IMAGE_TAG}" \
                        --set frontend.image.tag="${IMAGE_TAG}" \
                        --wait --timeout 5m
                '''
            }
        }
    }

    post {
        always {
            echo '🧹 Archiving security artifacts...'
            archiveArtifacts artifacts: 'trivy-reports/**', allowEmptyArchive: true
        }
        success {
            echo "🎉 Wonderlust CI/CD Pipeline executed successfully for tag: ${params.IMAGE_TAG}!"
        }
        failure {
            echo '❌ Wonderlust CI/CD Pipeline failed! Check logs above.'
        }
    }
}
