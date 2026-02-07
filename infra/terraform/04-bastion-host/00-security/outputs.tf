output "security_group_id" {
  description = "ID of the Bastion Security Group"
  value       = aws_security_group.bastion_sg.id
}

output "iam_instance_profile_name" {
  description = "Name of the Bastion IAM Instance Profile"
  value       = aws_iam_instance_profile.bastion_profile.name
}
