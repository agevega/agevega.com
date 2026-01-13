output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.id
}

output "acm_certificate_validation_options" {
  description = "DNS records required for ACM validation. Add these to your DNS provider."
  value       = aws_acm_certificate.cert.domain_validation_options
}

output "waf_web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}
