output "assets_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.assets.bucket_regional_domain_name
}

output "assets_bucket_id" {
  description = "The name of the assets bucket"
  value       = aws_s3_bucket.assets.id
}

output "assets_bucket_arn" {
  description = "The ARN of the assets bucket"
  value       = aws_s3_bucket.assets.arn
}
