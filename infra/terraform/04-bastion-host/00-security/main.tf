data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  tags = merge(var.common_tags, {
    Name        = "bastion-sg"
    Environment = var.environment
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

resource "aws_security_group_rule" "egress_ssh_to_vpc" {
  type              = "egress"
  description       = "SSH to instances in VPC"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr]
  security_group_id = aws_security_group.bastion_sg.id
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

resource "aws_security_group_rule" "egress_http" {
  type              = "egress"
  description       = "HTTP for package updates (yum/dnf)"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "egress_https" {
  type              = "egress"
  description       = "HTTPS for AWS services (ECR, SSM, etc.)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}
