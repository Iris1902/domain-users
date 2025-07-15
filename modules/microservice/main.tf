resource "aws_security_group" "sg" {
  name_prefix = "${var.name}-sg"
  vpc_id      = var.vpc_id

  # SSH (solo tú deberías limitar por IP si es producción)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puerto 80 (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puertos de microservicios (7000-7003)
  ingress {
    from_port   = 7000
    to_port     = 7003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = "${var.name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name}-lt"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data = base64encode(templatefile("${path.module}/docker-compose.tpl", {
    image_user_create = "ievinan/microservice-user-create:${var.branch}",
    port_user_create  = 7000,
    image_user_read   = "ievinan/microservice-user-read:${var.branch}",
    port_user_read    = 7001,
    image_user_update = "ievinan/microservice-user-update:${var.branch}",
    port_user_update  = 7002,
    image_user_delete = "ievinan/microservice-user-delete:${var.branch}",
    port_user_delete  = 7003,
    db_kind     = var.db_kind,
    jdbc_url    = var.jdbc_url,
    db_username = var.db_username,
    db_password = var.db_password
  }))
}

resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [var.subnet1, var.subnet2]
}

resource "aws_lb_target_group" "tg_create" {
  name     = "${var.name}-tg-create"
  port     = 7000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/api/users-create/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "tg_read" {
  name     = "${var.name}-tg-read"
  port     = 7001
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/api/users-read/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "tg_update" {
  name     = "${var.name}-tg-update"
  port     = 7002
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/api/users-update/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "tg_delete" {
  name     = "${var.name}-tg-delete"
  port     = 7003
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/api/users-delete/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_create.arn
  }
}

resource "aws_lb_listener_rule" "rule_create" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["/api/users-create*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_create.arn
  }
}

resource "aws_lb_listener_rule" "rule_read" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 101
  condition {
    path_pattern {
      values = ["/api/users-read*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_read.arn
  }
}

resource "aws_lb_listener_rule" "rule_update" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 102
  condition {
    path_pattern {
      values = ["/api/users-update*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_update.arn
  }
}

resource "aws_lb_listener_rule" "rule_delete" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 103
  condition {
    path_pattern {
      values = ["/api/users-delete*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_delete.arn
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = [var.subnet1, var.subnet2]
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  target_group_arns    = [
    aws_lb_target_group.tg_create.arn,
    aws_lb_target_group.tg_read.arn,
    aws_lb_target_group.tg_update.arn,
    aws_lb_target_group.tg_delete.arn
  ]
  lifecycle {
    create_before_destroy = true
  }
}
