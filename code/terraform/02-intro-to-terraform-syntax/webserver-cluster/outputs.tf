output "alb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_lb.example.dns_name
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.example.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.example.name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.asg.arn
}

output "alb_security_group_id" {
  description = "ID of the security group for the ALB"
  value       = aws_security_group.alb.id
}

output "instance_security_group_id" {
  description = "ID of the security group for EC2 instances"
  value       = aws_security_group.instance.id
}

output "vpc_subnet_ids" {
  description = "List of VPC subnet IDs used by the Auto Scaling Group"
  value       = data.aws_subnets.default.ids
}
