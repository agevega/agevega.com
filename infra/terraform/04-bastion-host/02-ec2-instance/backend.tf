terraform {
  backend "s3" {
    bucket         = "agevegacom-terraform-state"
    key            = "modules/02-bastion-EC2/03-instance/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "terraform"
  }
}
