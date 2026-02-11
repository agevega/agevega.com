data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/01-networking/00-vpc-core/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}
