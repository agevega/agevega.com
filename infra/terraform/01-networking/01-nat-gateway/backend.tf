terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/01-networking/01-nat-gateway/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
