output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = data.terraform_remote_state.security.outputs.eip_public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the Bastion Host"
  value       = aws_instance.bastion.id
}
