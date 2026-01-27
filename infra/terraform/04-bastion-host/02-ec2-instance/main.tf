resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = data.terraform_remote_state.networking.outputs.subnet_public_1_id

  key_name = data.terraform_remote_state.ssh_key.outputs.key_name

  vpc_security_group_ids = [data.terraform_remote_state.security.outputs.security_group_id]

  tags = merge(var.common_tags, {
    Name        = "bastion-host"
    Environment = var.environment
    Module      = "04-bastion-host/02-ec2-instance"
  })

  user_data = file("${path.module}/user_data.sh")
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = data.terraform_remote_state.eip.outputs.eip_allocation_id
}
