# USAGE INSTRUCTIONS:
# 1. Run 'terraform apply' first to create the bucket and table.
# 2. Once created, UNCOMMENT the 'terraform' block below.
# 3. Run 'terraform init -migrate-state' and type 'yes'.

# terraform {
#   backend "s3" {
#     bucket         = "agevegacom-terraform-state"
#     key            = "modules/00-setup/00-backend-S3/terraform.tfstate"
#     region         = "eu-south-2"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#     profile        = "terraform"
#   }
# }
