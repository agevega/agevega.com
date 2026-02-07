output "certificate_arn" {
  description = "ARN of the regional ACM certificate"
  value       = aws_acm_certificate.cert.arn
}
