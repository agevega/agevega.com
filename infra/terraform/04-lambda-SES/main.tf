# ------------------------------------------------------------------------------
# SES Identity
# ------------------------------------------------------------------------------
resource "aws_ses_email_identity" "default" {
  provider = aws.ses
  email    = var.sender_email
}

# ------------------------------------------------------------------------------
# IAM Role for Lambda
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-contact-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_ses_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = [
      aws_ses_email_identity.default.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_ses_permissions" {
  name   = "${var.project_name}-lambda-ses-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_ses_policy.json
}

# ------------------------------------------------------------------------------
# Lambda Function
# ------------------------------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "contact_form" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-contact-form"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  architectures    = ["arm64"]
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 5
  memory_size      = 128

  environment {
    variables = {
      SENDER_EMAIL    = var.sender_email
      RECIPIENT_EMAIL = var.recipient_email
      SES_REGION      = var.ses_region
    }
  }
}

# ------------------------------------------------------------------------------
# API Gateway (HTTP API)
# ------------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-contact-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["https://agevega.com", "https://www.agevega.com", "http://localhost:4321"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5
    throttling_rate_limit  = 1
  }
}

# ------------------------------------------------------------------------------
# CloudWatch Logs
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.contact_form.function_name}"
  retention_in_days = 1
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.contact_form.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "send_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /send"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
