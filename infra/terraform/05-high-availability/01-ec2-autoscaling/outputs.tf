output "alb_dns_name" {
  description = "The DNS name of the load balancer (shared between landing and academy)"
  value       = aws_lb.app_alb.dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group (shared, runs both landing and academy containers per instance)"
  value       = aws_autoscaling_group.app_asg.name
}

output "ssm_image_tag_name" {
  description = "Name of the SSM parameter storing the landing image tag for Production"
  value       = aws_ssm_parameter.image_tag.name
}

output "ssm_image_tag_name_academy" {
  description = "Name of the SSM parameter storing the academy image tag for Production"
  value       = aws_ssm_parameter.image_tag_academy.name
}
