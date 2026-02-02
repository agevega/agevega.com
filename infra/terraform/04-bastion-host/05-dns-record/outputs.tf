output "dev_url" {
  description = "Dev Environment URL"
  value       = "https://${aws_route53_record.dev.name}"
}
