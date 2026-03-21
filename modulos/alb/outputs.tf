output "alb_arn" {
  value       = try(aws_lb.this[0].arn, null)
  description = "ARN del ALB"
}

output "alb_dns_name" {
  value       = try(aws_lb.this[0].dns_name, null)
  description = "DNS público del ALB"
}

output "sg_id" {
  value       = try(aws_security_group.this[0].id, null)
  description = "ID del Security Group del ALB (null si create_security_group = false)"
}

output "tg_arns" {
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
  description = "Mapa de ARNs de todos los Target Groups (clave → ARN)"
}

output "http_listener_arn" {
  value       = try(aws_lb_listener.this["http"].arn, null)
  description = "ARN del listener HTTP (redirige a HTTPS)"
}

output "https_listener_arn" {
  value       = try(aws_lb_listener.this["https"].arn, null)
  description = "ARN del listener HTTPS"
}