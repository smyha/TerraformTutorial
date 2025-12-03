# ============================================================================
# TERRAGRUNT CONFIGURATION: Hello World App (Stage Environment)
# ============================================================================
# This file configures the hello-world-app service for the stage environment.
# It demonstrates key Terragrunt features:
#   - include: Inherits remote_state config from parent
#   - dependency: Automatically waits for MySQL to be deployed first
#   - inputs: Passes variables to the Terraform module
#   - source: Points to the reusable module
# ============================================================================

# ============================================================================
# TERRAFORM SOURCE
# ============================================================================
# Specifies which Terraform module to use. The double slash (//) is important:
# it tells Terragrunt to use the module at that path, not treat it as a
# relative path from the terragrunt.hcl file.
#
# Path breakdown:
#   ../../../../ = Go up 4 levels to repo root
#   modules// = The double slash means "use this exact path"
#   services/hello-world-app = The module directory
#
# This allows the same module to be used from different environments (stage/prod)
# while maintaining the same module code.
# ============================================================================
terraform {
  source = "../../../../modules//services/hello-world-app"
}

# ============================================================================
# INCLUDE BLOCK: Inherit Parent Configuration
# ============================================================================
# This block tells Terragrunt to look for and include the parent terragrunt.hcl
# file (in this case, live/stage/terragrunt.hcl).
#
# find_in_parent_folders():
#   - Searches up the directory tree for terragrunt.hcl
#   - Stops at the first one found (or repo root)
#   - Merges the parent's configuration with this file
#
# WHAT GETS INHERITED:
#   - remote_state configuration (backend settings)
#   - Any other shared configuration from parent
#
# This is the DRY principle: define backend config once, reuse everywhere.
# ============================================================================
include {
  path = find_in_parent_folders()
}

# ============================================================================
# DEPENDENCY BLOCK: Manage Module Dependencies
# ============================================================================
# This block declares that this module depends on the MySQL database module.
# Terragrunt will automatically:
#   1. Run `terragrunt apply` on the MySQL module first
#   2. Wait for it to complete successfully
#   3. Read its outputs
#   4. Make those outputs available as dependency.mysql.outputs
#   5. Then run `terragrunt apply` on this module
#
# BENEFITS:
#   - Automatic dependency management (no manual ordering needed)
#   - Safe: Can't deploy app before database exists
#   - Outputs are automatically passed between modules
#   - Works with terragrunt run-all commands
#
# config_path: Relative path to the dependent module's terragrunt.hcl
# ============================================================================
dependency "mysql" {
  config_path = "../../data-stores/mysql"
}

# ============================================================================
# INPUTS: Module Variables
# ============================================================================
# These are the input variables passed to the Terraform module. They override
# any defaults defined in the module's variables.tf file.
#
# SPECIAL INPUT: dependency.mysql.outputs
#   - This automatically passes all outputs from the MySQL module
#   - No need to manually read remote state or hardcode values
#   - Type-safe: Terragrunt validates the outputs exist
# ============================================================================
inputs = {
  environment = "stage"
  ami         = "ami-0fb653ca2d3203ac1"

  min_size = 2
  max_size = 2

  enable_autoscaling = false

  # Automatically pass all MySQL outputs to the app module
  # This includes: address, port, and any other outputs from MySQL
  mysql_config = dependency.mysql.outputs
}
