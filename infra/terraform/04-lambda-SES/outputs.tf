output "api_endpoint" {
  description = "The URL endpoint for the contact form API"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/send"
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.contact_form.function_name
}
