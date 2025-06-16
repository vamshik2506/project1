variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  type        = string
}

variable "vpc_name" {
  type        = string
}

variable "public_subnet_cidr" {
  type        = string
}

variable "private_subnet_cidr" {
  type        = string
}

variable "public_subnet_az" {
  type        = string
}

variable "private_subnet_az" {
  type        = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
