variable "name" {
  description = "Prefijo de nombres y tags"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC de la aplicación"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de subredes privadas para el ASG"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group del ALB (permitir solo ALB→app)"
  type        = string
}

variable "tg_arn" {
  description = "ARN del Target Group del ALB"
  type        = string
}

variable "app_port" {
  description = "Puerto de la aplicación"
  type        = number
  default     = 8080
}

variable "ami_id" {
  description = "AMI de las instancias"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre de la clave SSH (opcional)"
  type        = string
  default     = null
}

variable "iam_instance_profile_arn" {
  description = "ARN del Instance Profile IAM (opcional)"
  type        = string
  default     = null
}

variable "userdata" {
  description = "Script de arranque (user-data)"
  type        = string
  default     = ""
}

variable "desired" {
  description = "Capacidad deseada del ASG"
  type        = number
  default     = 2
}

variable "min" {
  description = "Capacidad mínima del ASG"
  type        = number
  default     = 2
}

variable "max" {
  description = "Capacidad máxima del ASG"
  type        = number
  default     = 6
}

variable "health_check_grace_period" {
  description = "Gracia (segundos) antes de evaluar health checks"
  type        = number
  default     = 120
}

variable "default_instance_warmup" {
  description = "Tiempo de warmup (segundos) para escalado"
  type        = number
  default     = 120
}

variable "enable_detailed_monitoring" {
  description = "Activar métricas a 1 minuto en EC2"
  type        = bool
  default     = true
}

variable "cpu_target" {
  description = "Objetivo de CPU (%) para Target Tracking"
  type        = number
  default     = 55
}

variable "use_alb_requests_metric" {
  description = "Usar RequestCountPerTarget del ALB para escalar"
  type        = bool
  default     = false
}

variable "alb_requests_target" {
  description = "Objetivo de req/s por instancia (si se usa métrica ALB)"
  type        = number
  default     = 100
}

variable "alb_arn_suffix" {
  description = "ARN suffix del ALB (para métrica ALB opcional)"
  type        = string
  default     = null
}

variable "tg_arn_suffix" {
  description = "ARN suffix del Target Group (para métrica ALB opcional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}