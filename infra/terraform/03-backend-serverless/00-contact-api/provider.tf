provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "agevega.com"
      Environment = "lab"
      ManagedBy   = "Terraform"
      Module      = "03-backend-serverless/00-contact-api"
    }
  }
}

provider "aws" {
  alias   = "ses"
  region  = var.ses_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "agevega.com"
      Environment = "lab"
      ManagedBy   = "Terraform"
      Module      = "03-backend-serverless/00-contact-api"
    }
  }
}
