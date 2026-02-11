terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/99-domain/01-acm-certificate/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
