output "security_group_id" {
  description = "ID of the Bastion Security Group"
  value       = aws_security_group.bastion_sg.id
}

