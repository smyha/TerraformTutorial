# ================================================================================
# TERRAFORM CONFIGURATION WITH WORKSPACES 
# ================================================================================
# Usefull for quick, isolated test on same configuration
# This configuration demonstrates Terraform Workspaces for managing multiple
# environments (dev, staging, prod) from a single codebase. Each workspace
# maintains its own state file and can have different resource configurations.

terraform {
  # Specify the minimum and maximum Terraform versions allowed
  required_version = ">= 1.0.0, < 2.0.0"

  # Define required providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Configure S3 as the remote backend for storing Terraform state
  # Note: When using workspaces with S3 backend, each workspace gets its own
  # state file path: s3://bucket/key/env:/workspace_name/terraform.tfstate
  backend "s3" {
    # NOTE: This backend configuration is filled in automatically at test time
    # by Terratest. If you wish to run this example manually, uncomment and
    # fill in the config below with your actual values.

    # bucket         = "<YOUR S3 BUCKET>"
    # key            = "<SOME PATH>/terraform.tfstate"
    # region         = "us-east-2"
    # dynamodb_table = "<YOUR DYNAMODB TABLE>"
    # encrypt        = true

    bucket         = "terraform-smyha"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-table"
    encrypt        = true
  }
}

# Configure the AWS provider to use the us-east-2 region
provider "aws" {
  region = "us-east-2"
}

# ================================================================================
# EC2 INSTANCE WITH WORKSPACE-AWARE CONFIGURATION
# ================================================================================
# This instance type varies based on the active workspace:
# - "default" workspace: t3.micro (Free Tier eligible - production-like)
# - All other workspaces: t3.small (Free Tier eligible - development)
#
# This demonstrates how to create environment-specific infrastructure from
# a single configuration file using conditional logic with terraform.workspace
#
# NOTE: t3.micro is the ONLY EC2 instance type eligible for AWS Free Tier.
# Both workspaces use it for cost control. To use different instance types
# in production (non-Free Tier), modify the instance_type line accordingly.

resource "aws_instance" "example" {
  # Ubuntu 20.04 LTS AMI in us-east-2
  ami = "ami-0fb653ca2d3203ac1"

  # Instance type depends on the current workspace
  # Syntax: condition ? value_if_true : value_if_false
  # - terraform.workspace: Built-in variable with current workspace name
  # - "default": The default workspace (always exists, created automatically)
  # - t3.micro: ONLY Free Tier eligible EC2 instance type
  #
  # For production deployments with different instance types per workspace:
  # instance_type = terraform.workspace == "default" ? "t3.small" : "t3.micro"
  # WARNING: Other instance types (t2.micro, t3.small, etc.) are NOT Free Tier eligible
  instance_type = terraform.workspace == "default" ? "t3.micro" : "t3.small"
}

