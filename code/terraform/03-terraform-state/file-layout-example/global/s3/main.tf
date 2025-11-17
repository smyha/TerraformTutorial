# ================================================================================
# TERRAFORM CONFIGURATION AND PROVIDER SETUP
# ================================================================================
# This configuration sets up the required Terraform version and AWS provider.
# It ensures compatibility with Terraform 1.x and uses AWS provider version 4.x.

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
}

# Configure the AWS provider to use the us-east-2 region
provider "aws" {
  region = "us-east-2"
}

# ================================================================================
# S3 BUCKET FOR TERRAFORM STATE STORAGE
# ================================================================================
# This S3 bucket stores the Terraform state files. The state file contains
# information about all the infrastructure managed by Terraform, including
# resource IDs, attributes, and metadata required for future operations.

resource "aws_s3_bucket" "terraform_state" {
  # Use the bucket name provided via variables (must be globally unique)
  bucket = var.bucket_name

  # This is only here so we can destroy the bucket as part of automated tests.
  # You should NOT use this in production! Production buckets should have this
  # set to false to prevent accidental destruction of critical state data.
  force_destroy = true
}

# ================================================================================
# S3 BUCKET VERSIONING
# ================================================================================
# Enable versioning to maintain a complete history of all state file changes.
# This allows you to recover previous versions of the state if needed, which is
# critical for debugging and understanding what changed in your infrastructure.

resource "aws_s3_bucket_versioning" "enabled" {
  # Reference the S3 bucket created above
  bucket = aws_s3_bucket.terraform_state.id

  # Enable versioning on the bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# ================================================================================
# S3 BUCKET ENCRYPTION CONFIGURATION
# ================================================================================
# Enable server-side encryption to protect state files at rest. This ensures
# that sensitive data stored in the Terraform state (database passwords,
# private keys, etc.) is encrypted using AWS S3's encryption mechanisms.

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  # Reference the S3 bucket created above
  bucket = aws_s3_bucket.terraform_state.id

  # Define the encryption rule
  rule {
    apply_server_side_encryption_by_default {
      # Use AWS S3-managed keys (AES256) for encryption
      # This is sufficient for most use cases and is cost-effective
      sse_algorithm = "AES256"
    }
  }
}

# ================================================================================
# S3 BUCKET PUBLIC ACCESS BLOCK
# ================================================================================
# Block all public access to the S3 bucket. This is a critical security measure
# because the Terraform state file contains sensitive information (credentials,
# resource IDs, private data) that should NEVER be accessible to the public.

resource "aws_s3_bucket_public_access_block" "public_access" {
  # Reference the S3 bucket created above
  bucket = aws_s3_bucket.terraform_state.id

  # Block public ACLs: Prevents anyone from using ACLs to grant public access
  block_public_acls = true

  # Block public bucket policies: Prevents bucket policies from granting public access
  block_public_policy = true

  # Ignore public ACLs: Treats any existing public ACLs as if they don't exist
  ignore_public_acls = true

  # Restrict public buckets: Prevents public access even if configured elsewhere
  restrict_public_buckets = true
}

# ================================================================================
# DYNAMODB TABLE FOR TERRAFORM STATE LOCKING
# ================================================================================
# This DynamoDB table implements state locking, which prevents concurrent
# Terraform operations from corrupting the state. When Terraform runs, it
# creates a lock entry in this table. If another Terraform process tries to
# run simultaneously, it will wait or fail, ensuring data consistency.

resource "aws_dynamodb_table" "terraform_locks" {
  # Use the table name provided via variables
  name = var.table_name

  # Use pay-per-request billing mode for cost efficiency (suitable for low traffic)
  billing_mode = "PAY_PER_REQUEST"

  # Define the primary key (hash key) for the lock table
  hash_key = "LockID"

  # Define the LockID attribute
  # This attribute will store unique identifiers for each Terraform state lock
  attribute {
    name = "LockID"
    # "S" = String type
    type = "S"
  }
}
