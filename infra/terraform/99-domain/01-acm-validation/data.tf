data "terraform_remote_state" "dns_zone" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/99-domain/00-dns-zone/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/02-shared-resources/01-acm-certificates/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}
