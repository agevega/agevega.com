output "security_group_id" {
  description = "ID of the Bastion Security Group"
  value       = aws_security_group.bastion_sg.id
}

output "key_name" {
  description = "Name of the Bastion Key Pair"
  value       = aws_key_pair.bastion_key.key_name
}

output "eip_public_ip" {
  description = "Public IP of the Bastion Elastic IP"
  value       = aws_eip.bastion_eip.public_ip
}

output "eip_allocation_id" {
  description = "Allocation ID of the Bastion Elastic IP"
  value       = aws_eip.bastion_eip.id
}
output "eip_public_dns" {
  description = "Public DNS of the Bastion Elastic IP"
  value       = aws_eip.bastion_eip.public_dns
}
