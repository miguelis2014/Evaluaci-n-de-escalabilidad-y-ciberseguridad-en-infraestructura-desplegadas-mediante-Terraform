output "sg_id" {
  value       = aws_security_group.app.id
  description = "Security Group de la aplicación"
}

output "asg_name" {
  value       = aws_autoscaling_group.asg.name
  description = "Nombre del Auto Scaling Group"
}

output "launch_template_id" {
  value       = aws_launch_template.lt.id
  description = "ID del Launch Template"
}