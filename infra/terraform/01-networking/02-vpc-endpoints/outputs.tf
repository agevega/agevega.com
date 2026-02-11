output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.vpce_s3.id
}

output "s3_vpc_endpoint_arn" {
  description = "The ARN of the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.vpce_s3.arn
}

output "s3_vpc_endpoint_cidr_blocks" {
  description = "The list of CIDR blocks for the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.vpce_s3.cidr_blocks
}

output "s3_vpc_endpoint_prefix_list_id" {
  description = "The prefix list ID of the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.vpce_s3.prefix_list_id
}
