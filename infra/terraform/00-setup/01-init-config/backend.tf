terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/00-setup/01-init-config/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
