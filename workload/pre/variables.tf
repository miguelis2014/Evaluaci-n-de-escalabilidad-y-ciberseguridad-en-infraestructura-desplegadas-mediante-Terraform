# Básicas
variable "name" {
    description = "Prefijo de nombres" 
    type = string 
}

variable "region" { 
    description = "Región AWS" 
    type = string 
    default = "eu-west-1" 
}

# Red
variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/20"
}

variable "project" { 
    description = "Nombre del proyecto" 
    type = string 
    default = "myproject" 
}

variable "environment" { 
    description = "Entorno de despliegue (dev, test, prod)" 
    type = string 
    default = "pre" 
}

variable "public_subnet_cidrs" {
  description = "CIDRs de subredes públicas (mínimo 2 AZ)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs de subredes privadas (mínimo 2 AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ALB
variable "alb_ingress_cidrs" {
  description = "CIDRs permitidos al ALB (80/443)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# variable "acm_certificate_arn" {
#   type        = string
#   description = "ARN del certificado ACM para el listener HTTPS del ALB"
#   default     = null
# }

# App / ASG
variable "ami_id" { 
    description = "AMI para las instancias" 
    type = string 
}

variable "instance_type" { 
    description = "Tipo de instancia"       
    type = string  
    default = "t3.micro"
}

variable "app_port" { 
    description = "Puerto de la app"         
    type = number  
    default = 8080 
}

variable "asg_desired" { 
    type = number 
    default = 2 
}

variable "asg_min" { 
    type = number 
    default = 2 
}
variable "asg_max" { 
    type = number 
    default = 6 
}

# Base de datos
variable "db_engine" { 
    type = string 
    default = "postgres" 
}

variable "db_engine_version" { 
    type = string 
    default = "15" 
}

variable "db_instance_class" { 
    type = string 
    default = "db.t3.micro" 
}

variable "db_name" { 
    type = string 
    default = "appdb" 
}

variable "db_user" { 
    type = string 
}

variable "db_pass" { 
    type = string 
    sensitive = true 
}