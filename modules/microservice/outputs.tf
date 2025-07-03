output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "lb_dns" {
  value = aws_lb.alb.dns_name
}
