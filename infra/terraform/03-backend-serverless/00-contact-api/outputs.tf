output "api_endpoint" {
  description = "The URL endpoint for the contact form API"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/send"
}

output "api_id" {
  description = "The ID of the HTTP API"
  value       = aws_apigatewayv2_api.http_api.id
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.contact_form.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.contact_form.arn
}

output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the API endpoint"
  value       = aws_ssm_parameter.api_endpoint.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for Lambda"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
