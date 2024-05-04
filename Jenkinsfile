template = '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: terraform
  name: terraform
spec:
  containers:
  - command:
    - sleep
    - "3600"
    image: hashicorp/terraform
    imagePullPolicy: Always
    name: terraform
    '''

tfvars = '''
region="us-east-2"
ami_id="ami-019f9b3318b7155c5"
az="us-east-2a"
'''

podTemplate(cloud: 'kubernetes', label: 'terraform', yaml: template) {
    node ("terraform") {
    container ("terraform") {
    stage ("Checkout SCM") {
        git branch: 'main', url: 'https://github.com/herabakirova/wordpress.git'
    }
    withCredentials([
        usernamePassword(credentialsId: 'aws-creds', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')
        ]) {
    stage ("Terraform init") {
        sh 'terraform init'
    }
    stage ("Terraform apply") {
        sh 'terraform apply'
    }
    }
}
}
}
