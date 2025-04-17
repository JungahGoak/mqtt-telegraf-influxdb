pipeline {
  agent any

  environment {
    DOCKER_CRED = credentials('dockerhub-cred-id')     // DockerHub 자격 증명
    KUBE_CRED = credentials('kubeconfig-cred-id')       // Kubeconfig 파일
    IMAGE_NAME = "${DOCKER_CRED_USR}/mqtt-telegraf-influx"
    IMAGE_TAG = "latest"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        sh '''
          echo "$DOCKER_CRED_PSW" | docker login -u "$DOCKER_CRED_USR" --password-stdin
          docker build -t $IMAGE_NAME:$IMAGE_TAG .
          docker push $IMAGE_NAME:$IMAGE_TAG
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        writeFile file: 'kubeconfig', text: "${KUBE_CRED}"
        sh '''
          export KUBECONFIG=$(pwd)/kubeconfig
          kubectl apply -f k8s/
        '''
      }
    }
  }
}
