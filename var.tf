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

variable "cidr_public2" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Provide CIDR block for public subnet 2"
}

variable "cidr_private1" {
  type        = string
  default     = "10.0.3.0/24"
  description = "Provide CIDR block for private subnet 1"
}

variable "cidr_private2" {
  type        = string
  default     = "10.0.4.0/24"
  description = "Provide CIDR block for private subnet 2"
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

variable "key_path" {
  type        = string
  default     = "/home/ubuntu/.ssh/id_rsa.pub"
  description = "Provide the path to public key"
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


variable "userdata" {
  type        = string
  default     = "./wp.sh"
  description = "description"
}
