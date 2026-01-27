provider "aws" {
  region  = "us-east-1" # WAF for CloudFront must be in US-East-1
  profile = var.aws_profile
}
