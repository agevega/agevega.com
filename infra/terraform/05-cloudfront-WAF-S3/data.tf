data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-agevegacom"
    key     = "envs/lab/agevegacom/02-bastion-EC2/00-security/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
