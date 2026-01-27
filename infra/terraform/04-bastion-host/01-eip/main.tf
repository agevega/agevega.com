resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  tags = merge(var.common_tags, {
    Name        = "bastion-eip"
    Environment = var.environment
    Module      = "04-bastion-host/01-eip"
  })
}
