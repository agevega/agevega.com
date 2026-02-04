data "terraform_remote_state" "s3_assets" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/02-shared-resources/02-s3-buckets/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/99-domain/01-acm-certificate/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "bastion_instance" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/04-bastion-host/02-ec2-instance/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "waf" {
  count   = var.enable_waf ? 1 : 0
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/04-bastion-host/03-waf/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
