terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "envs/lab/agevegacom/04-lambda-SES/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
