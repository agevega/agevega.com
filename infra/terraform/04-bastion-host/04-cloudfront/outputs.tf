output "cloudfront_domain_name_landing" {
  description = "The domain name of the landing CloudFront distribution"
  value       = aws_cloudfront_distribution.bastion_distribution_landing.domain_name
}

output "cloudfront_distribution_id_landing" {
  description = "The ID of the landing CloudFront distribution"
  value       = aws_cloudfront_distribution.bastion_distribution_landing.id
}

output "cloudfront_domain_name_academy" {
  description = "The domain name of the academy CloudFront distribution"
  value       = aws_cloudfront_distribution.bastion_distribution_academy.domain_name
}

output "cloudfront_distribution_id_academy" {
  description = "The ID of the academy CloudFront distribution"
  value       = aws_cloudfront_distribution.bastion_distribution_academy.id
}
