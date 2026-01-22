output "vpc_id" {
  description = "ID of the deployed VPC"
  value       = aws_vpc.agevegacom_vpc.id
}

output "subnet_public_1_id" {
  description = "ID of the first public subnet"
  value       = aws_subnet.public_subnet_1.id
}

output "subnet_public_2_id" {
  description = "ID of the second public subnet"
  value       = aws_subnet.public_subnet_2.id
}

output "subnet_public_3_id" {
  description = "ID of the third public subnet"
  value       = aws_subnet.public_subnet_3.id
}

output "subnet_private_1_id" {
  description = "ID of the first private subnet"
  value       = aws_subnet.private_subnet_1.id
}

output "subnet_private_2_id" {
  description = "ID of the second private subnet"
  value       = aws_subnet.private_subnet_2.id
}

output "subnet_private_3_id" {
  description = "ID of the third private subnet"
  value       = aws_subnet.private_subnet_3.id
}

output "subnet_db_1_id" {
  description = "ID of the first database subnet"
  value       = aws_subnet.db_subnet_1.id
}

output "subnet_db_2_id" {
  description = "ID of the second database subnet"
  value       = aws_subnet.db_subnet_2.id
}

output "subnet_db_3_id" {
  description = "ID of the third database subnet"
  value       = aws_subnet.db_subnet_3.id
}

output "igw_id" {
  description = "ID of the deployed Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public_route_table.id
}

# Exposed private route tables for other modules (like NAT Gateway) to add routes to
output "private_route_table_ids" {
  description = "Map of private route table IDs by AZ"
  value = {
    az0 = aws_route_table.private_route_table_1.id
    az1 = aws_route_table.private_route_table_2.id
    az2 = aws_route_table.private_route_table_3.id
  }
}

output "private_route_table_1_id" {
  description = "ID of the first private route table"
  value       = aws_route_table.private_route_table_1.id
}

output "private_route_table_2_id" {
  description = "ID of the second private route table"
  value       = aws_route_table.private_route_table_2.id
}

output "private_route_table_3_id" {
  description = "ID of the third private route table"
  value       = aws_route_table.private_route_table_3.id
}

output "db_route_table_1_id" {
  description = "ID of the first database route table"
  value       = aws_route_table.db_route_table_1.id
}

output "db_route_table_2_id" {
  description = "ID of the second database route table"
  value       = aws_route_table.db_route_table_2.id
}

output "db_route_table_3_id" {
  description = "ID of the third database route table"
  value       = aws_route_table.db_route_table_3.id
}
