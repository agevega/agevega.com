terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/01-networking/02-vpc-endpoints/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
