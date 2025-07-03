provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  token      = var.AWS_SESSION_TOKEN
}

# Módulos para cada microservicio de usuario
module "user_create" {
  source = "./modules/microservice"
  name   = "user-create"
  image  = "ievinan/microservice-user-create"
  port   = 7000
  branch = var.BRANCH_NAME
  db_kind     = var.DB_KIND
  jdbc_url    = var.JDBC_URL
  db_username = var.DB_USERNAME
  db_password = var.DB_PASSWORD
}

module "user_read" {
  source = "./modules/microservice"
  name   = "user-read"
  image  = "ievinan/microservice-user-read"
  port   = 7001
  branch = var.BRANCH_NAME
  db_kind     = var.DB_KIND
  jdbc_url    = var.JDBC_URL
  db_username = var.DB_USERNAME
  db_password = var.DB_PASSWORD
}

module "user_update" {
  source = "./modules/microservice"
  name   = "user-update"
  image  = "ievinan/microservice-user-update"
  port   = 7002
  branch = var.BRANCH_NAME
  db_kind     = var.DB_KIND
  jdbc_url    = var.JDBC_URL
  db_username = var.DB_USERNAME
  db_password = var.DB_PASSWORD
}

module "user_delete" {
  source = "./modules/microservice"
  name   = "user-delete"
  image  = "ievinan/microservice-user-delete"
  port   = 7003
  branch = var.BRANCH_NAME
  db_kind     = var.DB_KIND
  jdbc_url    = var.JDBC_URL
  db_username = var.DB_USERNAME
  db_password = var.DB_PASSWORD
}


# --- SNS Topic y Subscription para notificaciones ---
resource "aws_sns_topic" "asg_alerts" {
  name = "asg-alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.asg_alerts.arn
  protocol  = "email"
  endpoint  = "ievinan@uce.edu.ec"
}

# --- CloudWatch Alarm para el Auto Scaling Group (user-create como referencia) ---
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "asg-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarma si el promedio de CPU de las instancias del ASG supera el 70%"
  dimensions = {
    AutoScalingGroupName = module.user_create.asg_name
  }
  alarm_actions = [aws_sns_topic.asg_alerts.arn]
}

# --- CloudWatch Dashboard para monitoreo (user-create como referencia) ---
resource "aws_cloudwatch_dashboard" "asg_dashboard" {
  dashboard_name = "asg-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type" = "metric",
        "x" = 0,
        "y" = 0,
        "width" = 24,
        "height" = 6,
        "properties" = {
          "metrics" = [
            [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.user_create.asg_name ]
          ],
          "period" = 300,
          "stat" = "Average",
          "region" = var.AWS_REGION,
          "title" = "ASG CPU Utilization"
        }
      }
    ]
  })
}