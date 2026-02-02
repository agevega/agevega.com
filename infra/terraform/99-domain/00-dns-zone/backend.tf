terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/99-domain/00-dns-zone/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
