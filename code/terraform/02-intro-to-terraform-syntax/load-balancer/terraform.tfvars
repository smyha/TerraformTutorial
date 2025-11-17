# ============================================================================
# TERRAFORM VARIABLES VALUES
# ============================================================================
# This file contains the actual values for the variables defined in variables.tf
# These values override the default values specified in variables.tf

# AWS Region
aws_region = "us-east-2"

# Application Load Balancer name
alb_name = "terraform-asg-example"

# ALB security group name
alb_security_group_name = "terraform-example-alb"

# Instance security group name
instance_security_group_name = "terraform-example-instance"

# Target group name
target_group_name = "terraform-asg-example"

# Server port
server_port = 8080
