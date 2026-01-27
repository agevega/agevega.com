terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/03-backend-serverless/00-contact-api/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
