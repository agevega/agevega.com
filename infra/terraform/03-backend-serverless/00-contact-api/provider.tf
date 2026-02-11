provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "aws" {
  alias   = "ses"
  region  = var.ses_region
  profile = var.aws_profile
}
