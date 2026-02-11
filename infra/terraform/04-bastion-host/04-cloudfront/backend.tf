terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/04-bastion-host/04-cloudfront/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
