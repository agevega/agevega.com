data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/02-bastion-EC2/00-security/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
