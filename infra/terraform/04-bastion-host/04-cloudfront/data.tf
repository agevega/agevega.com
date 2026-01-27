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
    key     = "modules/02-shared-resources/01-acm-certificates/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "bastion_eip" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/04-bastion-host/01-eip/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "waf" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/04-bastion-host/03-waf/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
