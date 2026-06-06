variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-00e801948462f718a"
}

variable "key" {
  default = "mytfkey"
}

variable "instance-type" {
  default = "t3.micro"
}

variable "vpc-cidr" {
  default = "10.10.0.0/16"
}

variable "subnet1-cidr" {
  default = "10.10.1.0/24"
}

variable "subnet2-cidr" {
  default = "10.10.2.0/24"
}

variable "subnet1-az" {
  default = "us-east-1a"
}

variable "subnet2-az" {
  default = "us-east-1b"
}