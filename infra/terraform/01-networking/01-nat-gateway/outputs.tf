output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gw.id
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = aws_nat_gateway.nat_gw.public_ip
}

output "nat_eip_id" {
  description = "The allocation ID of the Elastic IP address for the NAT Gateway"
  value       = aws_eip.nat_eip.id
}

output "nat_eip_public_ip" {
  description = "The public IP address of the Elastic IP for the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}
