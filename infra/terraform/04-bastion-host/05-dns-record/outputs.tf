output "dev_landing_url" {
  description = "Dev Environment URL (landing)"
  value       = "https://${aws_route53_record.dev_landing.name}"
}

output "dev_academy_url" {
  description = "Dev Environment URL (academy)"
  value       = "https://${aws_route53_record.dev_academy.name}"
}
