output "landing_root_url" {
  description = "Production Environment URL (landing)"
  value       = "https://${aws_route53_record.landing_root.name}"
}

output "landing_www_url" {
  description = "Production Environment URL (landing WWW)"
  value       = "https://${aws_route53_record.landing_www.name}"
}

output "academy_root_url" {
  description = "Production Environment URL (academy)"
  value       = "https://${aws_route53_record.academy_root.name}"
}

output "academy_www_url" {
  description = "Production Environment URL (academy WWW)"
  value       = "https://${aws_route53_record.academy_www.name}"
}
