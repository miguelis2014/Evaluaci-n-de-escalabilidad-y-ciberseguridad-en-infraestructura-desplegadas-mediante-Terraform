output "alb_dns" {
  description = "DNS público del ALB"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos"
  value       = module.rds.endpoint
  sensitive   = false
}