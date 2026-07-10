resource "aws_instance" "my_tf_ec2" {
  ami           = var.ami
  instance_type = var.instance-type
  key_name = var.key
  associate_public_ip_address = true
  subnet_id = var.subnet_1_id
  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = "my_tf_ec2"
  }
}