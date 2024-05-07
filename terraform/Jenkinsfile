template = '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: docker
  name: docker
spec:
  containers:
  - command:
    - sleep
    - "3600"
    image: docker
    imagePullPolicy: Always
    name: docker
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker
  volumes:
  - name: docker
    hostPath:
      path: /var/run/docker.sock
    '''

def number = env.BUILD_NUMBER

podTemplate(cloud: 'kubernetes', label: 'docker', yaml: template) {
    node ("docker") {
    container ("docker") {
        stage ("Checkout SCM") {
        git branch: 'main', url: 'https://github.com/herabakirova/wordpress.git'
        }
        withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
        stage("Docker Build") {
        sh "docker build -t ${DOCKER_USER}/terraform:${number}.0 ./terraform"
        }
        stage("Docker Push") {
        sh """
        docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
        docker push ${DOCKER_USER}/terraform:${number}.0
        """
        }
    }
    }
    }
}

