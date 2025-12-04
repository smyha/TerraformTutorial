# ============================================================================
# Azure Resource Group Module - Variables
# ============================================================================
# This module creates an Azure Resource Group with standardized naming
# and tagging conventions.
# ============================================================================

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "application_name" {
  description = "The name of the application"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment for the resource group"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default     = "Spain Central"
}

variable "tags" {
  description = "A map of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}

