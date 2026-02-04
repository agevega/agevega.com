output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = var.enable_eip ? data.terraform_remote_state.eip[0].outputs.eip_public_ip : aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the Bastion Host"
  value       = aws_instance.bastion.id
}

output "bastion_public_dns" {
  description = "Public DNS of the Bastion Host"
  value       = aws_instance.bastion.public_dns
}
