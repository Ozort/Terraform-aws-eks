resource "aws_vpc" "my-tf-vpc" {
  cidr_block = var.vpc-cidr
}

resource "aws_subnet" "my-tf-subnet-1" {
  vpc_id     = aws_vpc.my-tf-vpc.id
  cidr_block = var.subnet1-cidr
  map_public_ip_on_launch = true
  availability_zone = var.subnet1-az

  tags = {
    Name = "my-tf-subnet-1"
  }
}

resource "aws_subnet" "my-tf-subnet-2" {
  vpc_id     = aws_vpc.my-tf-vpc.id
  cidr_block = var.subnet2-cidr
  map_public_ip_on_launch = true
  availability_zone = var.subnet2-az

  tags = {
    Name = "my-tf-subnet"
  }
}

resource "aws_internet_gateway" "my-tf-igw" {
  vpc_id = aws_vpc.my-tf-vpc.id

  tags = {
    Name = "my-tf-igw"
  }
}

resource "aws_route_table" "my-tf-rt" {
  vpc_id = aws_vpc.my-tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-tf-igw.id
  }
  tags = {
    Name = "my-tf-rt"
  }
}

resource "aws_route_table_association" "my-tf-rt_association-1" {
  subnet_id      = aws_subnet.my-tf-subnet-1.id

  route_table_id = aws_route_table.my-tf-rt.id
}

resource "aws_route_table_association" "my-tf-rt_association-2" {
  subnet_id      = aws_subnet.my-tf-subnet-2.id

  route_table_id = aws_route_table.my-tf-rt.id
}

resource "aws_security_group" "my-tf-vpc-sg" {
  name        = "my-tf-vpc-sg"
  vpc_id      = aws_vpc.my-tf-vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.my-tf-vpc-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.my-tf-vpc-sg.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.my-tf-vpc-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.my-tf-vpc-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}