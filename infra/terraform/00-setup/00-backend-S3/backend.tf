# INSTRUCCIONES DE USO:
# 1. Ejecuta 'terraform apply' primero para crear el bucket y la tabla.
# 2. Una vez creados, DESCOMENTA el bloque 'terraform' de abajo.
# 3. Ejecuta 'terraform init -migrate-state' y escribe 'yes'.

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-agevegacom"
#     key            = "envs/global/00-backend-S3/terraform.tfstate"
#     region         = "eu-south-2"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#     profile        = "terraform"
#   }
# }
