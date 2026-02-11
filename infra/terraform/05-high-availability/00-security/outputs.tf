output "alb_sg_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "instance_sg_id" {
  description = "Security Group ID for EC2 instances"
  value       = aws_security_group.instances_sg.id
}

output "iam_instance_profile_name" {
  description = "IAM Instance Profile name for EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}
