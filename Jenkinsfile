pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'  // Docker Hub
        DOCKER_USERNAME = 'goak65'  // Docker Hub 사용자명
        IMAGE_NAME = 'mqtt-telegraf-influxdb'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                }
            }
        }
        
        stage('Build') {
            steps {
                // Docker 이미지 빌드
                sh "docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                // Kubernetes 매니페스트 업데이트
                sh """
                    sed -i '' 's|image: .*|image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/*.yaml
                """
                
                // Kubernetes에 배포
                sh "kubectl apply -f k8s/"
            }
        }
    }
    
    post {
        always {
            // 작업 공간 정리
            cleanWs()
            // Docker 로그아웃
            sh 'docker logout'
        }
    }
} 