data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/01-networking/00-vpc-core/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/03-ECR/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "ssh_key" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/02-bastion-EC2/01-ssh-key/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket  = "agevegacom-terraform-state"
    key     = "modules/06-ha-autoscaling/00-security/terraform.tfstate"
    region  = "eu-south-2"
    profile = "terraform"
  }
}
