# 1) Red: VPC + subredes + IGW + rutas públicas (SIN NAT)
module "vpc" {
  source = "../../modulos/vpc"

  project        = var.project
  environment    = var.environment
  region         = var.region

  vpc_name = var.name
  vpc_cidr = var.vpc_cidr

  azs = ["a", "b"]

  # Subredes públicas (ALB)
  public_subnets = [
    {
      sname = "${var.name}-public-a"
      CIDR  = "10.0.0.0/24"
      AZ    = "a"
      tags  = {}
    },
    {
      sname = "${var.name}-public-b"
      CIDR  = "10.0.1.0/24"
      AZ    = "b"
      tags  = {}
    }
  ]

  # Subredes privadas aisladas (ASG + RDS)
  private_subnets_isolated = [
    {
      sname = "${var.name}-private-a"
      CIDR  = "10.0.10.0/24"
      AZ    = "a"
      tags  = {}
    },
    {
      sname = "${var.name}-private-b"
      CIDR  = "10.0.11.0/24"
      AZ    = "b"
      tags  = {}
    }
  ]

  common_tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# 2) ALB público en subredes públicas
module "alb" {
  source            = "../../modulos/alb"
  create               = true
  load_balancer_type   = "application"
  name                 = "${var.name}-alb"
  vpc_id               = module.vpc.vpc_id
  subnets              = module.vpc.public_subnet_ids
  create_security_group = true
  security_group_ingress_rules = {
    http = {
      from_port = 80
      to_port   = 80
      cidr_ipv4 = "0.0.0.0/0"
    }
    https = {
      from_port = 443
      to_port   = 443
      cidr_ipv4 = "0.0.0.0/0"
    }
  }

  target_groups = {
    app = {
      name        = "${var.name}-tg"
      port        = 8080
      protocol    = "HTTP"
      target_type = "instance"
      vpc_id      = module.vpc.vpc_id
      create_attachment = false
      health_check = {
        path    = "/health"
        matcher = "200"
      }
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        status_code = "HTTP_301"
        port        = "443"
        protocol    = "HTTPS"
      }
    }
    https = {
      port           = 443
      protocol       = "HTTPS"
      forward        = { target_group_key = "app" }
    }
  }

}

# 3) ASG EC2 en subredes privadas
module "asg" {
  source             = "../../modulos/asg_ec2"
  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_sg_id     = module.alb.sg_id
  tg_arn        = module.alb.tg_arns["app"]
  ami_id        = var.ami_id
  instance_type = var.instance_type
  app_port      = var.app_port

  desired = var.asg_desired
  min     = var.asg_min
  max     = var.asg_max

  iam_instance_profile_arn = aws_iam_instance_profile.app.arn

  # demo simple: sirve "Hello" en el puerto app_port
  userdata = file("../common/userdata.sh")
}

# Política de confianza: solo EC2 puede asumir este rol
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.name}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  description        = "Rol IAM para instancias EC2 de la aplicación"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_policy" "app" {
  name        = "${var.name}-app-policy"
  description = "Permisos mínimos para las EC2 de la aplicación (least privilege)"
  policy      = data.aws_iam_policy_document.app_permissions.json
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}

# Instance Profile — lo que se asigna al ASG
resource "aws_iam_instance_profile" "app" {
  name = "${var.name}-app-profile"
  role = aws_iam_role.app.name
}

# 4) RDS privado (Multi-AZ) accesible solo desde la app
module "rds" {
  source             = "../../modulos/rds"
  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.asg.sg_id

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_user
  password       = var.db_pass

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
}

# ############# Posibles mejoras #############
# resource "aws_secretsmanager_secret" "db_password" {
#   name                    = "/${var.project}/${var.environment}/rds/password"
#   description             = "Contraseña RDS para ${var.name}"
#   recovery_window_in_days = 7

#   tags = {
#     Project     = var.project
#     Environment = var.environment
#   }
# }

# resource "aws_secretsmanager_secret_version" "db_password" {
#   secret_id     = aws_secretsmanager_secret.db_password.id
#   secret_string = jsonencode({ password = var.db_pass })
# }