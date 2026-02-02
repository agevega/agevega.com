output "zone_id" {
  description = "Route53 Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "domain_name" {
  description = "Domain Name"
  value       = aws_route53_zone.main.name
}
