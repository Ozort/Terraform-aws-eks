#Defaut values will only be applied if specific values are not defined in the .tfvars file

variable "region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ami" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "key" {
  type        = string
  description = "Name of the SSH key pair"
}

variable "instance-type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "vpc-cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.10.0.0/16"
}

variable "subnet1-cidr" {
  type        = string
  description = "CIDR block for the subnet1"
  default     = "10.10.1.0/24"
}

variable "subnet2-cidr" {
  type        = string
  description = "CIDR block for the subnet2"
  default     = "10.10.2.0/24"
}

variable "subnet1-az" {
  type        = string
  description = "Availability zone for the subnet"
  default     = "us-east-1a"
}

variable "subnet2-az" {
  type        = string
  description = "Availability zone for the subnet"
  default     = "us-east-1b"
}