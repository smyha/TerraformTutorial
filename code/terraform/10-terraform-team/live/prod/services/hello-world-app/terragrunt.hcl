# ============================================================================
# TERRAGRUNT CONFIGURATION: Hello World App (Production Environment)
# ============================================================================
# Production configuration for the hello-world-app service. This demonstrates
# how the same module can be used across environments with different inputs.
#
# PRODUCTION CONSIDERATIONS:
#   - Should have more instances (min_size/max_size) for high availability
#   - Should enable autoscaling for traffic spikes
#   - Should use production-grade AMIs
#   - Should have monitoring and alerting configured
#   - Should use production database (dependency on prod MySQL)
# ============================================================================

terraform {
  source = "../../../../modules//services/hello-world-app"
}

include {
  path = find_in_parent_folders()
}

# ============================================================================
# DEPENDENCY: Production MySQL Database
# ============================================================================
# This app depends on the production MySQL database. Terragrunt will:
#   1. Apply the MySQL module first
#   2. Wait for it to complete
#   3. Read its outputs (address, port)
#   4. Make them available as dependency.mysql.outputs
#   5. Then apply this app module
#
# This ensures the database exists before the app tries to connect to it.
# ============================================================================
dependency "mysql" {
  config_path = "../../data-stores/mysql"
}

# ============================================================================
# INPUTS: Production Configuration
# ============================================================================
# Production-specific inputs. In a real production environment, you might:
#   - Increase min_size/max_size for high availability
#   - Enable autoscaling (enable_autoscaling = true)
#   - Use a more recent/production AMI
#   - Add additional monitoring/alerting configuration
# ============================================================================
inputs = {
  environment = "prod"
  ami         = "ami-0fb653ca2d3203ac1"

  # Production should typically have more instances for redundancy
  # Consider: min_size = 3, max_size = 10 for production
  min_size = 2
  max_size = 2

  # Production should typically have autoscaling enabled
  # Consider: enable_autoscaling = true
  enable_autoscaling = false

  # Automatically pass production MySQL outputs to the app
  # This includes the production database address and port
  mysql_config = dependency.mysql.outputs
}