# ============================================================================
# Azure Resource Group Module - Main Configuration
# ============================================================================
# This module creates an Azure Resource Group with standardized naming
# and tagging conventions.
#
# Naming Convention:
# - Format: {project_name}-{application_name}-{environment}
# - If application_name is empty, uses abbreviation
# - Example: "myproject-vnm-prod" or "myproject-rg-prod"
# ============================================================================

# ----------------------------------------------------------------------------
# Local Values
# ----------------------------------------------------------------------------
locals {
  # Abbreviation for resource group (used when application_name is empty)
  abbreviation = "rg"

  # Generate resource group name
  # Format: {project_name}-{application_name or abbreviation}-{environment}
  resource_group_name = var.application_name != "" ? join("-", [var.project_name, var.application_name, var.environment]) : join("-", [var.project_name, local.abbreviation, var.environment])
}

# ----------------------------------------------------------------------------
# Resource Group
# ----------------------------------------------------------------------------
# Creates an Azure Resource Group with standardized naming and tags
# ----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = var.tags
}

