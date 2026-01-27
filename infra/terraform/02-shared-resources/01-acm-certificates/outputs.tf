output "certificate_arn" {
  description = "The ARN of the ACM Certificate"
  value       = aws_acm_certificate.cert.arn
}

output "certificate_validation_options" {
  description = "DNS records required for ACM validation"
  value       = aws_acm_certificate.cert.domain_validation_options
}
