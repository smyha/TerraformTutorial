terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    # This backend configuration is filled in automatically at test time by Terratest. If you wish to run this example
    # manually, uncomment and fill in the config below.

    # bucket         = "<YOUR S3 BUCKET>"
    # key            = "<SOME PATH>/terraform.tfstate"
    # region         = "us-east-2"
    # dynamodb_table = "<YOUR DYNAMODB TABLE>"
    # encrypt        = true
  }
}

# ============================================================================
# STAGING ENVIRONMENT: MySQL Database Configuration
# ============================================================================
# This configuration uses the mysql module (modules/data-stores/mysql) to deploy
# a single MySQL RDS instance in the staging environment.
#
# KEY DIFFERENCES FROM PRODUCTION:
#   - Production (live/prod/data-stores/mysql): Uses multi-region replication
#     with a primary database in us-east-2 and a replica in us-west-1 for
#     high availability and disaster recovery.
#   - Staging (this file): Uses a single database instance without replication
#     to reduce costs and complexity, as pre-production environments typically
#     don't require the same level of availability.
#
# DESIGN DECISIONS:
#   1. Single provider (no aliases): Staging doesn't need multi-region setup
#   2. No replication: backup_retention_period and replicate_source_db are
#      not set, so the module creates a standalone primary database
#   3. Single region: All resources in us-east-2 for simplicity
#   4. Cost optimization: Staging environments prioritize cost savings over
#      high availability
#
# SOLUTION IMPLEMENTATION:
#   - Uses the same mysql module as production for consistency
#   - Omits replication parameters to create a standalone instance
#   - Can be easily upgraded to replication later if needed by adding:
#     * backup_retention_period = 1
#     * replicate_source_db = <primary_arn> (in a second module call)
# ============================================================================

provider "aws" {
  region = "us-east-2"
  # Note: No alias needed for staging since we only use one region
  # Compare to production which uses aws.primary and aws.replica aliases
}

# ============================================================================
# MODULE: MySQL Database (Standalone, No Replication)
# ============================================================================
# This module call creates a single MySQL RDS instance without replication.
# The module's conditional logic (in modules/data-stores/mysql/main.tf) will:
#   - Set engine = "mysql" (since replicate_source_db is null)
#   - Set db_name, username, password (since replicate_source_db is null)
#   - Skip backup_retention_period (defaults to null, no backups enabled)
#
# To add replication later (if staging requirements change):
#   1. Add a second provider with alias = "replica" pointing to another region
#   2. Add backup_retention_period = 1 to enable backups (required for replication)
#   3. Create a second module call with replicate_source_db = module.mysql.arn
#   4. See live/prod/data-stores/mysql/main.tf for the production pattern
# ============================================================================
module "mysql" {
  source = "../../../../modules/data-stores/mysql"

  # Required parameters for a primary (non-replica) database
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # Replication is intentionally NOT configured for staging:
  # - backup_retention_period is not set (defaults to null)
  # - replicate_source_db is not set (defaults to null)
  # This results in a standalone primary database without read replicas
  #
  # If you need replication in staging, uncomment and configure:
  # backup_retention_period = 1  # Required for replication
  # Then add a second module call for the replica (see prod example)
}
