data "terraform_remote_state" "s3_assets" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/05-cloudfront-WAF-S3/00-s3-assets/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/05-cloudfront-WAF-S3/01-acm-certificate/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "bastion_eip" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/02-bastion-EC2/02-eip/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
