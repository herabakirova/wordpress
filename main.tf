provider "aws" {
  region     = var.region
  access_key = "????"
  secret_key = "????"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public2
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_private1
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_private2
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.cidr_route
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.cidr_route
    gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  vpc_id      = aws_vpc.vpc.id
  description = "Allow TLS inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private1.cidr_block]
  }
}

resource "aws_security_group" "deny_all" {
  vpc_id = aws_vpc.vpc.id
  name   = "db"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public1.cidr_block]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress = []
}

resource "aws_key_pair" "deployer" {
  key_name   = "project"
  public_key = file(var.key_path)
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.deny_all.id]
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
}

output "db_endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "Endpoint of the MySQL DB"
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public1.id
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_tls.id]
  user_data       = file(var.userdata)
  depends_on = [
    aws_db_instance.mysql
  ]
}
resource "null_resource" "wp" {
  depends_on = [
    aws_instance.web
  ]
  connection {
    host        = aws_instance.web.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install -y apache2 php libapache2-mod-php php-mysql",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2",
      "cd /var/www/html",
      "sudo rm index.html",
      "sudo wget https://wordpress.org/latest.tar.gz",
      "sudo tar -xzf latest.tar.gz",
      "sudo mv wordpress/* .",
      "sudo rm -rf wordpress latest.tar.gz",
      "sudo chown -R www-data:www-data /var/www/html",
      "sudo cp wp-config-sample.php wp-config.php",
      "sudo sed -i 's/database_name_here/${aws_db_instance.mysql.db_name}/g' wp-config.php",
      "sudo sed -i 's/username_here/${var.db_username}/g' wp-config.php",
      "sudo sed -i 's/password_here/${var.db_password}/g' wp-config.php",
      "sudo sed -i 's/localhost/${aws_db_instance.mysql.endpoint}/g' wp-config.php",
      "sudo systemctl restart apache2"
    ]
  }
}
