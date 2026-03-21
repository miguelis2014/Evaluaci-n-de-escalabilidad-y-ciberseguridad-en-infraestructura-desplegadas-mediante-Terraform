locals {
  tags = merge(
    { Project = var.name, Module = "asg_ec2" },
    var.tags
  )
}

# SG de la app: SOLO recibe del SG del ALB
resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "Permite tráfico desde el ALB hacia la app"
  vpc_id      = var.vpc_id

  ingress {
    description     = "ALB -> app"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    description = "Salida a cualquier destino (p.ej. RDS en la VPC)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Seguridad y red
  network_interfaces {
    security_groups             = [aws_security_group.app.id]
    associate_public_ip_address = false
  }

  # Requiere IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 1
  }

  # Métricas a 1-min (si enabled)
  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_arn != null ? [1] : []
    content {
      arn = var.iam_instance_profile_arn
    }
  }

  user_data = var.userdata == "" ? null : base64encode(var.userdata)

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${var.name}-app" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.name}-asg"
  desired_capacity          = var.desired
  min_size                  = var.min
  max_size                  = var.max
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.tg_arn]
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period
  default_instance_warmup   = var.default_instance_warmup

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  # Propaga tags a instancias
  tag {
    key                 = "Project"
    value               = var.name
    propagate_at_launch = true
  }
  tag {
    key                 = "Module"
    value               = "asg_ec2"
    propagate_at_launch = true
  }
}

# Escalado por CPU media del ASG (recomendado)
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.name}-cpu-tt"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target
  }
}

# (Opcional) Escalado por peticiones en el ALB (RequestCountPerTarget)
resource "aws_autoscaling_policy" "alb_req_target_tracking" {
  count                  = var.use_alb_requests_metric && var.alb_arn_suffix != null && var.tg_arn_suffix != null ? 1 : 0
  name                   = "${var.name}-alb-req-tt"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.alb_arn_suffix}/${var.tg_arn_suffix}"
    }
    target_value = var.alb_requests_target
  }
}