output "key_name" {
  description = "Name of the Bastion Key Pair"
  value       = aws_key_pair.bastion_key.key_name
}
