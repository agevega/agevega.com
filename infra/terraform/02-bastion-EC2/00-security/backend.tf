terraform {
  backend "s3" {
    bucket         = "terraform-state-agevegacom"
    key            = "envs/lab/agevegacom/02-bastion-EC2/00-security/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
