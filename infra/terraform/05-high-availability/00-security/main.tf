data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "alb_sg" {
  name        = "ha-cluster-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(var.common_tags, {
    Name = "ha-cluster-alb-sg"
  })
}

resource "aws_security_group_rule" "alb_ingress_cloudfront" {
  type              = "ingress"
  description       = "HTTP from CloudFront"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_egress_to_instances" {
  type                     = "egress"
  description              = "HTTP to instances (health checks and traffic)"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.instance_sg.id
}

resource "aws_security_group" "instance_sg" {
  name        = "ha-cluster-instance-sg"
  description = "Security group for EC2 instances in ASG"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(var.common_tags, {
    Name = "ha-cluster-instance-sg"
  })
}

resource "aws_security_group_rule" "instance_ingress_ssh_from_bastion" {
  type                     = "ingress"
  description              = "SSH from Bastion"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.instance_sg.id
  source_security_group_id = data.terraform_remote_state.bastion.outputs.security_group_id
}

resource "aws_security_group_rule" "instance_ingress_http_from_alb" {
  type                     = "ingress"
  description              = "HTTP from ALB"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.instance_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "instance_egress_https" {
  type              = "egress"
  description       = "HTTPS for AWS services (ECR, SSM, CloudWatch)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance_sg.id
}
