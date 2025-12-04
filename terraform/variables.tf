variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "ecommerce-spring"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami" {
  type    = string
  # Amazon Linux 2 / General AMI - change if you want Ubuntu
  default = "ami-0ecb62995f68bb549" # replace with region-appropriate AMI
}

variable "key_name" {
  type        = string
  default = e-com
}

variable "db_engine" {
  type    = string
  default = "mysql"
}

variable "db_username" {
  type    = string
  default = "ecomadmin"
}

variable "db_password" {
  type        = string
  description = "Initial DB password. We will create an SSM SecureString; keep sensitive."
  sensitive   = true
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "public_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

