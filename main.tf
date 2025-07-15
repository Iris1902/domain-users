provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  token      = var.AWS_SESSION_TOKEN
}

module "domain_users" {
  source = "./modules/microservice"
  name   = "domain-users"
  image_user_create = "ievinan/microservice-user-create"
  port_user_create  = 7000
  image_user_read   = "ievinan/microservice-user-read"
  port_user_read    = 7001
  image_user_update = "ievinan/microservice-user-update"
  port_user_update  = 7002
  image_user_delete = "ievinan/microservice-user-delete"
  port_user_delete  = 7003
  branch     = var.BRANCH_NAME
  db_kind    = var.DB_KIND
  jdbc_url   = var.JDBC_URL
  db_username= var.DB_USERNAME
  db_password= var.DB_PASSWORD
  vpc_id     = var.vpc_id
  subnet1    = var.subnet1
  subnet2    = var.subnet2
}

resource "aws_sns_topic" "asg_alerts" {
  name = "asg-alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.asg_alerts.arn
  protocol  = "email"
  endpoint  = "ievinan@uce.edu.ec"
}

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
    AutoScalingGroupName = module.domain_users.asg_name
  }
  alarm_actions = [aws_sns_topic.asg_alerts.arn]
}

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
            [ "AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.domain_users.asg_name ]
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