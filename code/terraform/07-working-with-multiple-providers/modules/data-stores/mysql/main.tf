/*
 * MySQL data-store module
 *
 * This module is intentionally tiny, but it demonstrates the cross-region /
 * cross-account replication knobs that Chapter 7 focuses on. The idea is:
 *   - When `replicate_source_db` is null, create a brand-new primary MySQL RDS
 *     instance with credentials and a database name.
 *   - When `replicate_source_db` is set, treat this module invocation as a read
 *     replica. In that case the engine/db_name/username/password fields must be
 *     unset, so we guard them with ternaries below.
 *   - `backup_retention_period` is optional, but if you plan to create replicas
 *     you must retain at least 1 day of backups; the module surfaces that as a
 *     variable so that multi-region deployments can coordinate their retention.
 */

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_db_instance" "example" {
  # A short identifier prefix keeps names unique across regions without forcing
  # callers to pass explicit identifiers.
  identifier_prefix   = "terraform-up-and-running"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true

  # Retain automated backups so downstream replicas (possibly in other
  # accounts/regions) can catch up when network blips happen.
  backup_retention_period = var.backup_retention_period

  # If `replicate_source_db` is provided, AWS treats this instance as a read
  # replica; otherwise it is a standalone primary.
  replicate_source_db = var.replicate_source_db

  # Only set the engine + credentials when creating a primary DB (AWS blocks
  # these arguments when building replicas).
  engine   = var.replicate_source_db == null ? "mysql" : null
  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null
}
