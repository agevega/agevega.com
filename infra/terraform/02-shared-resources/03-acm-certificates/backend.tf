terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/02-shared-resources/03-acm-certificates/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
