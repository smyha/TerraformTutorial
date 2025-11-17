# ============================================================================
# VARIABLES: Configurable parameters for the load balancer
# ============================================================================

# Variable: AWS Region
variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-2"
}

# Variable: Application Load Balancer name
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "terraform-asg-example"

  validation {
    condition     = length(var.alb_name) <= 32
    error_message = "ALB name must be 32 characters or less."
  }
}

# Variable: ALB security group name
variable "alb_security_group_name" {
  description = "Name of the security group for the ALB"
  type        = string
  default     = "terraform-example-alb"
}

# Variable: Instance security group name
variable "instance_security_group_name" {
  description = "Name of the security group for EC2 instances"
  type        = string
  default     = "terraform-example-instance"
}

# Variable: Target group name
variable "target_group_name" {
  description = "Name of the ALB target group"
  type        = string
  default     = "terraform-asg-example"

  validation {
    condition     = length(var.target_group_name) <= 32
    error_message = "Target group name must be 32 characters or less."
  }
}

# Variable: Server port for the web server
variable "server_port" {
  description = "Port number for the web server to listen on"
  type        = number
  default     = 8080

  validation {
    condition     = var.server_port > 1024 && var.server_port < 65536
    error_message = "Server port must be between 1024 and 65535."
  }
}
