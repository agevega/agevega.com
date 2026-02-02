terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/99-domain/02-dns-records/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
