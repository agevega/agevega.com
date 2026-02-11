provider "aws" {
  region  = "us-east-1" # ACM Certificate for CloudFront must be in us-east-1
  profile = var.aws_profile
}
