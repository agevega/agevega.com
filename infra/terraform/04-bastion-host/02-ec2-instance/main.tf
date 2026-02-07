resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = data.terraform_remote_state.networking.outputs.subnet_public_1_id

  key_name = data.terraform_remote_state.ssh_key.outputs.key_name
  
  iam_instance_profile = data.terraform_remote_state.security.outputs.iam_instance_profile_name

  vpc_security_group_ids = [data.terraform_remote_state.security.outputs.security_group_id]

  # Force IMDSv2 to prevent SSRF credential theft
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.common_tags, {
    Name        = "bastion-host"
    Environment = var.environment
  })

  user_data = file("${path.module}/user_data.sh")
}

resource "aws_eip_association" "eip_assoc" {
  count         = var.enable_eip ? 1 : 0
  instance_id   = aws_instance.bastion.id
  allocation_id = data.terraform_remote_state.eip[0].outputs.eip_allocation_id
}

resource "aws_ssm_parameter" "bastion_public_dns" {
  name        = "/${var.project_name}/04-bastion-host/02-ec2-instance/bastion-public-dns"
  description = "Bastion Host Public DNS"
  type        = "String"
  value       = aws_instance.bastion.public_dns

  tags = var.common_tags
}
