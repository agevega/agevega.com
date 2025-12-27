terraform {
  backend "s3" {
    bucket         = "terraform-state-agevegacom"
    key            = "envs/lab/agevegacom/00-backend-S3/01-init-config/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
