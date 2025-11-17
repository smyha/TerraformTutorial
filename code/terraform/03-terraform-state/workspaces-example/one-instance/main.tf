# ================================================================================
# TERRAFORM CONFIGURATION WITH WORKSPACES
# ================================================================================
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
# - "default" workspace: t2.medium (suitable for production)
# - All other workspaces: t2.micro (cost-effective for dev/testing)
#
# This demonstrates how to create environment-specific infrastructure from
# a single configuration file using conditional logic with terraform.workspace

resource "aws_instance" "example" {
  # Ubuntu 20.04 LTS AMI in us-east-2
  ami = "ami-0fb653ca2d3203ac1"

  # Instance type depends on the current workspace
  # Syntax: condition ? value_if_true : value_if_false
  # - terraform.workspace: Built-in variable with current workspace name
  # - "default": The default workspace (always exists, created automatically)
  # - t2.medium: Larger instance for production/default environment
  # - t2.micro: Smaller instance for development environments
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}

