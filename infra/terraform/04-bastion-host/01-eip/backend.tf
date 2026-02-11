terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/04-bastion-host/01-eip/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
