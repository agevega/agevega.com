terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/02-shared-resources/03-acm-certificates/terraform.tfstate"
    region         = "eu-south-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    profile        = "terraform"
  }
}
