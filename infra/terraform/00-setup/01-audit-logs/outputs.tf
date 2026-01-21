output "cloudtrail_arn" {
  description = "ARN of the main CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "config_recorder_id" {
  description = "ID of the AWS Config Recorder"
  value       = aws_config_configuration_recorder.main.id
}
