terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/04-bastion-host/00-security/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
