# ============================================================================
# EXAMPLE: Application Load Balancer (ALB)
# ============================================================================
# This is a standalone example demonstrating how to use the ALB module
# without Terragrunt. It shows the traditional Terraform approach where
# you manually configure everything.
#
# COMPARISON WITH TERRAGRUNT:
#   - Without Terragrunt: You'd need to manually write backend.tf in each module
#   - With Terragrunt: Backend config is inherited from parent terragrunt.hcl
#   - Without Terragrunt: Manual dependency management via remote_state data sources
#   - With Terragrunt: Automatic dependency management via dependency blocks
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
# MODULE: Application Load Balancer
# ============================================================================
# This example uses the reusable ALB module from modules/networking/alb.
# In a Terragrunt setup, this would be configured via terragrunt.hcl instead
# of directly in main.tf.
# ============================================================================
module "alb" {
  source = "../../modules/networking/alb"

  alb_name = var.alb_name

  subnet_ids = data.aws_subnets.default.ids
}
