# Wordpress Installation with Jenkins CI/CD pipeline.

```hcl
module "wordpress" {
source = "herabakirova/1/wordpress"
version = "0.0.1"
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
key_path = "/home/ubuntu/.ssh/id_rsa.pub"
db_subnet_name = "main"
db_name = "mysql_db"
db_instance_class = "db.t3.micro"
db_username = ""
db_password = ""
instance_name = "wordpress"
userdata = "./wp.sh"
}
```