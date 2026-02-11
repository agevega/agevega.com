terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/05-high-availability/02-waf/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
