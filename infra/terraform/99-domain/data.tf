data "terraform_remote_state" "bastion_cloudfront" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/04-bastion-host/04-cloudfront/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}
