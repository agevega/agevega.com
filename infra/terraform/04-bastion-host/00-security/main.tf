resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  tags = merge(var.common_tags, {
    Name        = "bastion-sg"
    Environment = var.environment
    Module      = "04-bastion-host/00-security"
  })
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  description       = "SSH from allowed IPs"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidr_blocks
  security_group_id = aws_security_group.bastion_sg.id
}



resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

# ------------------------------------------------------------------------------
# CloudFront Access Rule
# ------------------------------------------------------------------------------
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "ingress_cloudfront_http" {
  type              = "ingress"
  description       = "Allow CloudFront Origin Traffic"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.bastion_sg.id
}

