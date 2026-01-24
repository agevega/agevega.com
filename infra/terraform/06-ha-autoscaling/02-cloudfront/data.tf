data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/05-cloudfront-WAF-S3/01-acm-certificate/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "waf" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/06-ha-autoscaling/01-waf/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "main" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/06-ha-autoscaling/00-main/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
