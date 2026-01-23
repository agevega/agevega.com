resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  tags = merge(var.common_tags, {
    Name        = "bastion-eip"
    Environment = var.environment
    Module      = "02-bastion-EC2/02-eip"
  })
}
