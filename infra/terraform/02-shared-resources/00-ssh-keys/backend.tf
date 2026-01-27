terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/02-shared-resources/00-ssh-keys/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
