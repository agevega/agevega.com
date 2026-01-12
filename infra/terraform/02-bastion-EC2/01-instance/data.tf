data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-agevegacom"
    key     = "envs/lab/agevegacom/01-networking/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-agevegacom"
    key     = "envs/lab/agevegacom/02-bastion-EC2/00-security/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}
