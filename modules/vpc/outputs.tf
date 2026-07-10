output "vpc_id" {
  value = aws_vpc.my_tf_vpc.id
}

output "sg_id" {
  value = aws_security_group.my_tf_vpc_sg.id
}

output "subnet_1_id" {
  value = aws_subnet.my_tf_subnet_1.id
}

output "subnet_2_id" {
  value = aws_subnet.my_tf_subnet_2.id
}

