data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/01-networking/00-vpc-core/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
