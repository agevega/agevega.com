data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/01-networking/00-vpc-core/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/04-bastion-host/00-security/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}
