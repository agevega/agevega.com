terraform {
  backend "s3" {
    bucket         = "terraform-state-agevegacom"
    key            = "envs/lab/agevegacom/05-cloudfront-WAF-S3/terraform.tfstate"
    region         = "eu-south-2"
    profile        = "terraform"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
