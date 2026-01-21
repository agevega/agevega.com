output "state_bucket_name" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the state S3 bucket"
  value       = aws_s3_bucket.tf_state.arn
}

output "lock_table_name" {
  description = "DynamoDB table for locking"
  value       = aws_dynamodb_table.tf_lock.name
}
