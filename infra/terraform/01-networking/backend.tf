terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "envs/lab/agevegacom/01-networking/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
