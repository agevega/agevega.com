output "vpc_id" {
  description = "ID de la VPC desplegada"
  value       = aws_vpc.agevegacom_vpc.id
}

output "subnet_public_1_id" {
  description = "ID de la primera subred pública"
  value       = aws_subnet.public_subnet_1.id
}

output "subnet_public_2_id" {
  description = "ID de la segunda subred pública"
  value       = aws_subnet.public_subnet_2.id
}

output "subnet_public_3_id" {
  description = "ID de la tercera subred pública"
  value       = aws_subnet.public_subnet_3.id
}

output "subnet_private_1_id" {
  description = "ID de la primera subred privada"
  value       = aws_subnet.private_subnet_1.id
}

output "subnet_private_2_id" {
  description = "ID de la segunda subred privada"
  value       = aws_subnet.private_subnet_2.id
}

output "subnet_private_3_id" {
  description = "ID de la tercera subred privada"
  value       = aws_subnet.private_subnet_3.id
}

output "subnet_db_1_id" {
  description = "ID de la primera subred de bases de datos"
  value       = aws_subnet.db_subnet_1.id
}

output "subnet_db_2_id" {
  description = "ID de la segunda subred de bases de datos"
  value       = aws_subnet.db_subnet_2.id
}

output "subnet_db_3_id" {
  description = "ID de la tercera subred de bases de datos"
  value       = aws_subnet.db_subnet_3.id
}

output "igw_id" {
  description = "ID del Internet Gateway desplegado"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID de la tabla de enrutamiento pública"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table_1_id" {
  description = "ID de la primera tabla de enrutamiento privada"
  value       = aws_route_table.private_route_table_1.id
}

output "private_route_table_2_id" {
  description = "ID de la segunda tabla de enrutamiento privada"
  value       = aws_route_table.private_route_table_2.id
}

output "private_route_table_3_id" {
  description = "ID de la tercera tabla de enrutamiento privada"
  value       = aws_route_table.private_route_table_3.id
}

output "db_route_table_1_id" {
  description = "ID de la primera tabla de enrutamiento para bases de datos"
  value       = aws_route_table.db_route_table_1.id
}

output "db_route_table_2_id" {
  description = "ID de la segunda tabla de enrutamiento para bases de datos"
  value       = aws_route_table.db_route_table_2.id
}

output "db_route_table_3_id" {
  description = "ID de la tercera tabla de enrutamiento para bases de datos"
  value       = aws_route_table.db_route_table_3.id
}
