variable "name" {
  description = "Prefijo de nombres y tags"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crea RDS"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de subredes privadas para el DB Subnet Group"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security Group de la app que puede acceder a RDS"
  type        = string
}

variable "engine" {
  description = "Motor de base de datos (postgres/mysql, etc.)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Versión del motor"
  type        = string
  default     = "15"
}

variable "instance_class" {
  description = "Clase de instancia de RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nombre de la base de datos inicial"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Usuario administrador de la base de datos"
  type        = string
}

variable "password" {
  description = "Contraseña del usuario administrador"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Almacenamiento (GB)"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Alta disponibilidad Multi-AZ"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Retención de backups automáticos (días)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Ventana de backups automáticos (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "deletion_protection" {
  description = "Protección contra borrado accidental."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Si true, no crea snapshot al destruir. false en producción"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Acceso público (debe ser false en este diseño)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}