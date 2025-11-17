# ============================================================================
# OUTPUTS: Display important information after Terraform apply
# ============================================================================

# Output: The ALB DNS name
output "alb_dns_name" {
  description = "The domain name of the load balancer"
  value       = aws_lb.example.dns_name
}

# Output: The ALB ARN
output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.example.arn
}

# Output: Target group ARN
output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.asg.arn
}

# Output: ALB security group ID
output "alb_security_group_id" {
  description = "ID of the security group for the ALB"
  value       = aws_security_group.alb.id
}

# Output: Instance security group ID
output "instance_security_group_id" {
  description = "ID of the security group for EC2 instances"
  value       = aws_security_group.instance.id
}
