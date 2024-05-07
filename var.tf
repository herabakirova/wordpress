variable "region" {
  type        = string
  default     = "us-east-2"
  description = "Provide the region"
}

variable "cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Provide CIDR block"
}

variable "cidr_public1" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Provide CIDR block for public subnet 1"
}

variable az_public1 {
  type        = string
  default     = "us-east-2a"
  description = "Provide AZ for public subnet 1"
}


variable "cidr_public2" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Provide CIDR block for public subnet 2"
}

variable az_public2 {
  type        = string
  default     = "us-east-2b"
  description = "Provide AZ for public subnet 2"
}

variable "cidr_private1" {
  type        = string
  default     = "10.0.3.0/24"
  description = "Provide CIDR block for private subnet 1"
}

variable az_private1 {
  type        = string
  default     = "us-east-2a"
  description = "Provide AZ for private subnet 1"
}

variable "cidr_private2" {
  type        = string
  default     = "10.0.4.0/24"
  description = "Provide CIDR block for private subnet 2"
}

variable az_private2 {
  type        = string
  default     = "us-east-2b"
  description = "Provide AZ for private subnet 2"
}

variable "cidr_route" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Provide CIDR block for route table"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Provide instance type"
}

variable "az" {
  type        = string
  default     = "us-east-2a"
  description = "Provide AZ for instance"
}

variable key_name {
  type        = string
  default     = "project"
  description = "Provide key name for key pair"
}


variable "key_path" {
  type        = string
  default     = "/home/ubuntu/.ssh/id_rsa.pub"
  description = "Provide the path to public key"
}
variable db_subnet_name {
  type        = string
  default     = "main"
  description = "Provide the name for database subnet"
}

variable "db_name" {
  type        = string
  default     = "mysql_db"
  description = "description"
}

variable db_instance_class {
  type        = string
  default     = "db.t3.micro"
  description = "description"
}

variable "db_username" {
  type        = string
  default     = "hera"
  description = "description"
}

variable "db_password" {
  type        = string
  default     = "kaizen123" #REPLACE
  description = "description"
}

variable instance_name {
  type        = string
  default     = "wordpress"
  description = "Provide the name for instance"
}

variable "userdata" {
  type        = string
  default     = "./wp.sh"
  description = "description"
}
