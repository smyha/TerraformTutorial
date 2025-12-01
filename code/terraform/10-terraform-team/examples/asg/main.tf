# ============================================================================
# EXAMPLE: Auto Scaling Group (ASG)
# ============================================================================
# This is a standalone example demonstrating how to use the ASG module
# without Terragrunt. It shows the traditional Terraform approach.
#
# This example:
#   - Uses the asg-rolling-deploy module
#   - Dynamically looks up the latest Ubuntu AMI
#   - Creates a simple ASG with 1 instance (for testing)
# ============================================================================

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# ============================================================================
# MODULE: Auto Scaling Group with Rolling Deploy
# ============================================================================
# This module creates an ASG with rolling deployment capabilities.
# In a Terragrunt setup, the source and variables would be configured
# in terragrunt.hcl, keeping the Terraform code cleaner.
# ============================================================================
module "asg" {
  source = "../../modules/cluster/asg-rolling-deploy"

  cluster_name = var.cluster_name

  # Dynamically look up the latest Ubuntu AMI instead of hardcoding
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  # Small size for example/testing purposes
  min_size           = 1
  max_size           = 1
  enable_autoscaling = false

  subnet_ids = data.aws_subnets.default.ids
}

# ============================================================================
# DATA SOURCE: Latest Ubuntu AMI
# ============================================================================
# This data source dynamically finds the most recent Ubuntu 20.04 AMI.
# This is better than hardcoding an AMI ID because:
#   - AMIs are region-specific
#   - AMIs get updated with security patches
#   - Hardcoded AMIs can become unavailable
# ============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}