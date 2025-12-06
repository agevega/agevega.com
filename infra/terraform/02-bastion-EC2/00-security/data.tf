data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-agevegacom"
    key     = "envs/lab/agevegacom/01-networking/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
