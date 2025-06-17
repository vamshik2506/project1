variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for public subnet A"
  type        = string
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for public subnet B"
  type        = string
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for private subnet A"
  type        = string
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for private subnet B"
  type        = string
}

variable "public_subnet_az_a" {
  description = "Availability Zone for public subnet A"
  type        = string
}

variable "public_subnet_az_b" {
  description = "Availability Zone for public subnet B"
  type        = string
}

variable "private_subnet_az_a" {
  description = "Availability Zone for private subnet A"
  type        = string
}

variable "private_subnet_az_b" {
  description = "Availability Zone for private subnet B"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name for EC2 access"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}
