output "zone_id" {
  description = "Route53 Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "dev_url" {
  description = "Dev Environment URL"
  value       = "https://${aws_route53_record.dev.name}"
}
