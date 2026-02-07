data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/99-domain/00-dns-zone/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "aws_route53_zone" "selected" {
  name         = data.terraform_remote_state.dns.outputs.domain_name
  private_zone = false
}
