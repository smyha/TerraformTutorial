# ================================================================================
# TERRAFORM CONFIGURATION AND REMOTE STATE BACKEND
# ================================================================================
# This configuration deploys a MySQL database using RDS. The state is stored
# remotely in S3 with state locking via DynamoDB to ensure safe concurrent access.

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
  # This keeps the state file away from local machine for team collaboration
  # and provides centralized state management.
  backend "s3" {
    # NOTE: This backend configuration is filled in automatically at test time
    # by Terratest. If you wish to run this example manually, uncomment and
    # fill in the config below with your actual values.

    # bucket         = "<YOUR S3 BUCKET>"         # S3 bucket name (e.g., "my-terraform-state")
    # key            = "<SOME PATH>/terraform.tfstate"  # Path within bucket (e.g., "stage/data-stores/mysql/terraform.tfstate")
    # region         = "us-east-2"                 # AWS region where S3 bucket is located
    # dynamodb_table = "<YOUR DYNAMODB TABLE>"    # DynamoDB table for state locking
    # encrypt        = true                        # Enable encryption for state in transit

  }
}

# Configure the AWS provider to use the us-east-2 region
provider "aws" {
  region = "us-east-2"
}

# ================================================================================
# RDS MYSQL DATABASE INSTANCE
# ================================================================================
# This creates a managed MySQL database in AWS RDS. RDS handles backups,
# patches, and maintenance automatically. The database outputs (address and
# port) are stored in the state file and can be read by other Terraform
# configurations using terraform_remote_state data sources.

resource "aws_db_instance" "example" {
  # Prefix for the database instance identifier
  # The actual identifier will be: terraform-up-and-running-XXXX (XXXX = random suffix)
  identifier_prefix = "terraform-up-and-running"

  # Database engine to use
  engine = "mysql"

  # Storage allocation in GB
  allocated_storage = 10

  # Instance class determines the compute and memory resources
  # db.t2.micro is eligible for AWS free tier (if account is new)
  instance_class = "db.t2.micro"

  # Skip the final DB snapshot when destroying
  # WARNING: Setting this to true means data loss on destroy!
  # For production, use false and keep snapshots for recovery
  skip_final_snapshot = true

  # Database name (initial database to create)
  db_name = var.db_name

  # Master username for the database administrator
  username = var.db_username

  # Master user password (should come from environment variables for security)
  password = var.db_password
}
