terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/03-backend-serverless/00-contact-api/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "eu-south-2"
    profile        = "terraform"
    encrypt        = true
  }
}
