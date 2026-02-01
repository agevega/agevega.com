resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  tags = merge(var.common_tags, {
    Name        = "bastion-eip"
    Environment = var.environment
    Module      = "04-bastion-host/01-eip"
  })
}

resource "aws_ssm_parameter" "bastion_ip" {
  name        = "/${var.project_name}/04-bastion-host/01-eip/bastion-ip"
  description = "Bastion Host Public IP"
  type        = "String"
  value       = aws_eip.bastion_eip.public_ip

  tags = merge(var.common_tags, {
    Module = "04-bastion-host/01-eip"
  })
}
