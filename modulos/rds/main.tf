locals {
  tags = merge(
    { Project = var.name, Module = "rds" },
    var.tags
  )

  db_port = var.engine == "mysql" ? 3306 : 5432
}

# SG de la base de datos: SOLO permite tráfico desde el SG de la app
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Permite acceso a RDS unicamente desde la app"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App to RDS"
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  # egress abierto (hacia servicios gestionados dentro de la VPC)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# Subnet group en subredes PRIVADAS
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.private_subnet_ids
  tags       = local.tags
}

# Instancia RDS (Multi-AZ por defecto, privada y cifrada)
resource "aws_db_instance" "this" {
  identifier                   = "${var.name}-rds"
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class

  db_name  = var.db_name
  username = var.username
  password = var.password

  allocated_storage            = var.allocated_storage
  storage_type                 = "gp3"
  storage_encrypted            = true
  publicly_accessible          = var.publicly_accessible
  multi_az                     = var.multi_az
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.rds.id]
  port                         = local.db_port

  # Backups/retención
  backup_retention_period      = var.backup_retention_period
  backup_window                = var.backup_window
  maintenance_window           = var.maintenance_window
  auto_minor_version_upgrade   = true
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : "${var.name}-rds-final-snapshot"

  tags = local.tags
}