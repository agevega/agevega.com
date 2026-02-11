terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/01-networking/00-vpc-core/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
