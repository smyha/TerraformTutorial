/*
 * Helper module that demonstrates how to accept multiple AWS provider aliases.
 * It does not create resources on its own—the root modules call it mainly to
 * show how to pass the correct provider configurations down to nested modules.
 * The data sources capture caller identity for both accounts so examples can
 * log/verify which account they're targeting.
 */

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.0"
      configuration_aliases = [aws.parent, aws.child]
    }
  }
}

data "aws_caller_identity" "parent" {
  provider = aws.parent
}

data "aws_caller_identity" "child" {
  provider = aws.child
}
