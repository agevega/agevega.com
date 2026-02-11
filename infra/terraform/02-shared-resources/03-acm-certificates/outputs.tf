output "certificate_arn" {
  description = "ARN of the regional ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.cert.status
}
