provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "agevega.com"
      Environment = "lab"
      ManagedBy   = "Terraform"
      Module      = "04-lambda-SES"
    }
  }
}
