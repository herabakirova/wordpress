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
    image: herabakirova/terraform:21.0
    imagePullPolicy: Always
    name: terraform
    '''

    properties([
      parameters([
        choice(choices: ['apply', 'destroy'], description: 'Pick the action', name: 'action')
        ])
        ])
podTemplate(cloud: 'kubernetes', label: 'terraform', yaml: template) {
    node ("terraform") {
    container ("terraform") {
    stage ("Checkout SCM") {
        git branch: 'dev', url: 'https://github.com/herabakirova/wordpress.git'
    }
    withCredentials([
        usernamePassword(credentialsId: 'aws-creds', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID'),
        file(credentialsId: 'word', variable: 'wordpress')
        ]) {
    stage ("Terraform init") {
        sh 'terraform init'
    }

  if(params.action == "apply") {
    stage ("Terraform apply and destroy") {
      sh "terraform apply -var-file ${wordpress} --auto-approve"
    }
  }
  
  else {
      stage ("Terraform destroy"){
      sh "terraform destroy -var-file ${wordpress} --auto-approve"
    }
  }

}
}
}
} 