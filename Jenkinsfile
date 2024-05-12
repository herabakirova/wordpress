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

tfvars = '''
region = "us-east-2"
cidr = "10.0.0.0/16"
cidr_public1 = "10.0.1.0/24"
az_public1 = "us-east-2a"
cidr_public2 = "10.0.2.0/24"
az_public2 = "us-east-2b"
cidr_private1 = "10.0.3.0/24"
az_private1 = "us-east-2a"
cidr_private2 = "10.0.4.0/24"
az_private2 = "us-east-2b"
cidr_route = "0.0.0.0/0"
instance_type = "t2.micro"
az = "us-east-2a"
key_name = "project"
key_path = "/home/bakirovahera/.ssh/id_rsa.pub"
db_subnet_name = "main"
db_name = "mysql_db"
db_instance_class = "db.t3.micro"
db_username = ""
db_password = ""
instance_name = "wordpress"
userdata = "./wp.sh"
'''

podTemplate(cloud: 'kubernetes', label: 'terraform', yaml: template) {
    node ("terraform") {
    container ("terraform") {
    stage ("Checkout SCM") {
        git branch: 'dev', url: 'https://github.com/herabakirova/wordpress.git'
    }
    withCredentials([
        usernamePassword(credentialsId: 'aws-creds', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID'),
        file(credentialsId: 'tfvars', variable: 'kaizen')
        ]) {
    stage ("Terraform init") {
        sh 'terraform init'
    }
    writeFile file: 'hello.tfvars', text: tfvars
    stage ("Terraform apply and destroy") {
      sh "terraform apply -var-file hello.tfvars --auto-approve"
      sh "terraform destroy -var-file hello.tfvars --auto-approve"
    }

}
}
}
} 