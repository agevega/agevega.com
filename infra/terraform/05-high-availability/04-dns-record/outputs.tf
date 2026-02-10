output "root_url" {
  description = "Production Environment URL"
  value       = "https://${aws_route53_record.root.name}"
}

output "www_url" {
  description = "Production Environment URL (WWW)"
  value       = "https://${aws_route53_record.www.name}"
}
