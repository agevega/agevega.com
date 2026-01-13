provider "aws" {
  region  = "eu-south-2"
  profile = "terraform"
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "terraform"
}
