provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public1
  availability_zone       = var.az_public1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_public2
  availability_zone       = var.az_public2
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private1
  availability_zone = var.az_private1
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_private2
  availability_zone = var.az_private2
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

resource "aws_security_group" "scrgrp_instance" {
  name        = "sg-instance"
  vpc_id      = aws_vpc.vpc.id

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "scrgrp_db" {
  vpc_id = aws_vpc.vpc.id
  name   = "sg-db"
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key-project" {
  key_name   = var.key_name
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
  name       = var.db_subnet_name
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.scrgrp_db.id]
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public1.id
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.scrgrp_instance.id]
  user_data       = var.userdata
  tags = {
    Name = var.instance_name
  }
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
      "sudo apt update",
      "sudo apt install apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip -y",
      "sudo mkdir -p /srv/www",
      "sudo systemctl start apache2",
      "sudo chown www-data: /srv/www",
      "curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www",
      "echo '<VirtualHost *:80>\nDocumentRoot /srv/www/wordpress\n<Directory /srv/www/wordpress>\nOptions FollowSymLinks\nAllowOverride Limit Options FileInfo\nDirectoryIndex index.php\nRequire all granted\n</Directory>\n<Directory /srv/www/wordpress/wp-content>\nOptions FollowSymLinks\nRequire all granted\n</Directory>\n</VirtualHost>' | sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null",
      "sudo a2ensite wordpress",
      "sudo a2enmod rewrite",
      "sudo a2dissite 000-default",
      "sudo service apache2 reload",
      "sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php",
      "sudo sed -i 's/database_name_here/${aws_db_instance.mysql.db_name}/g' /srv/www/wordpress/wp-config.php",
      "sudo sed -i 's/username_here/${var.db_username}/g' /srv/www/wordpress/wp-config.php",
      "sudo sed -i 's/password_here/${var.db_password}/g' /srv/www/wordpress/wp-config.php",
      "sudo sed -i 's/localhost/${aws_db_instance.mysql.endpoint}/g' /srv/www/wordpress/wp-config.php",
      "sudo service apache2 reload"
    ]
  }
}

