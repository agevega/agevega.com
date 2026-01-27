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
