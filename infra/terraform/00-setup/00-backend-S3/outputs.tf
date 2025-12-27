output "state_bucket_name" {
  description = "Bucket S3 para el estado de Terraform"
  value       = aws_s3_bucket.tf_state.bucket
}

output "state_bucket_arn" {
  description = "ARN del bucket S3 de estado"
  value       = aws_s3_bucket.tf_state.arn
}

output "lock_table_name" {
  description = "Tabla DynamoDB para locking"
  value       = aws_dynamodb_table.tf_lock.name
}
