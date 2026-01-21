terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/00-setup/02-budgets/terraform.tfstate"
    region         = "eu-south-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    profile        = "terraform"
  }
}
