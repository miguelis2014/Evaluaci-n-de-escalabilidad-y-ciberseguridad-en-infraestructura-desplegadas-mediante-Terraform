output "security_group_id" {
  description = "ID del Security Group de RDS"
  value       = aws_security_group.rds.id
}

output "subnet_group_name" {
  description = "Nombre del DB Subnet Group"
  value       = aws_db_subnet_group.this.name
}

output "endpoint" {
  description = "Endpoint DNS de la base de datos"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Puerto de la base de datos"
  value       = aws_db_instance.this.port
}

output "identifier" {
  description = "Identificador de la instancia RDS"
  value       = aws_db_instance.this.identifier
}