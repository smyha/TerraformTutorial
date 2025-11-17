variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-2"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "terraform-asg-example"
  validation {
    condition     = length(var.alb_name) <= 32
    error_message = "ALB name must be 32 characters or less."
  }
}

variable "alb_security_group_name" {
  description = "Name of the security group for the ALB"
  type        = string
  default     = "terraform-example-alb"
}

variable "instance_security_group_name" {
  description = "Name of the security group for EC2 instances"
  type        = string
  default     = "terraform-example-instance"
}

variable "target_group_name" {
  description = "Name of the ALB target group"
  type        = string
  default     = "terraform-asg-example"
  validation {
    condition     = length(var.target_group_name) <= 32
    error_message = "Target group name must be 32 characters or less."
  }
}

variable "server_port" {
  description = "Port number for the web server to listen on"
  type        = number
  default     = 8080
  validation {
    condition     = var.server_port > 1024 && var.server_port < 65536
    error_message = "Server port must be between 1024 and 65535."
  }
}

variable "instance_type" {
  description = "EC2 instance type (e.g., t2.micro, t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Amazon Machine Image ID for EC2 instances"
  type        = string
  default     = "ami-0fb653ca2d3203ac1"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
  validation {
    condition     = var.min_size >= 1 && var.min_size <= 10
    error_message = "Min size must be between 1 and 10."
  }
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 10
  validation {
    condition     = var.max_size >= 1 && var.max_size <= 20
    error_message = "Max size must be between 1 and 20."
  }
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
  validation {
    condition     = var.desired_capacity >= 1 && var.desired_capacity <= 20
    error_message = "Desired capacity must be between 1 and 20."
  }
}
