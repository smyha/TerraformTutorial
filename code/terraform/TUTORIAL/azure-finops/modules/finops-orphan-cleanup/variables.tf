# ============================================================================
# Azure FinOps Orphan Cleanup Module - Variables
# ============================================================================

variable "resource_group_id" {
  description = "The ID of the Resource Group to save the queries in. Format: /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}"
  type        = string
}

variable "query_type" {
  description = "Type of Resource Graph query. Options: 'private' or 'public'."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public"], var.query_type)
    error_message = "Query type must be 'private' or 'public'."
  }
}

# Orphaned Disks Query
variable "create_orphaned_disks_query" {
  description = "Whether to create a query for orphaned (unattached) managed disks."
  type        = bool
  default     = true
}

variable "orphaned_disks_query_name" {
  description = "Name of the orphaned disks query."
  type        = string
  default     = "find-orphaned-disks"
}

variable "orphaned_disks_query_description" {
  description = "Description of the orphaned disks query."
  type        = string
  default     = "Finds managed disks that are not attached to any VM."
}

variable "orphaned_disks_query" {
  description = "Custom KQL query for orphaned disks. If null, uses default."
  type        = string
  default     = null
}

# Orphaned Public IPs Query
variable "create_orphaned_public_ips_query" {
  description = "Whether to create a query for orphaned (unused) public IP addresses."
  type        = bool
  default     = true
}

variable "orphaned_public_ips_query_name" {
  description = "Name of the orphaned public IPs query."
  type        = string
  default     = "find-orphaned-public-ips"
}

variable "orphaned_public_ips_query_description" {
  description = "Description of the orphaned public IPs query."
  type        = string
  default     = "Finds Public IPs that are not associated with any network interface."
}

variable "orphaned_public_ips_query" {
  description = "Custom KQL query for orphaned public IPs. If null, uses default."
  type        = string
  default     = null
}

# Orphaned NICs Query
variable "create_orphaned_nics_query" {
  description = "Whether to create a query for orphaned (unattached) network interfaces."
  type        = bool
  default     = false
}

variable "orphaned_nics_query_name" {
  description = "Name of the orphaned NICs query."
  type        = string
  default     = "find-orphaned-nics"
}

variable "orphaned_nics_query_description" {
  description = "Description of the orphaned NICs query."
  type        = string
  default     = "Finds network interfaces that are not attached to any VM."
}

variable "orphaned_nics_query" {
  description = "Custom KQL query for orphaned NICs. If null, uses default."
  type        = string
  default     = null
}

# Orphaned Storage Accounts Query
variable "create_orphaned_storage_accounts_query" {
  description = "Whether to create a query for potentially orphaned storage accounts."
  type        = bool
  default     = false
}

variable "orphaned_storage_accounts_query_name" {
  description = "Name of the orphaned storage accounts query."
  type        = string
  default     = "find-orphaned-storage-accounts"
}

variable "orphaned_storage_accounts_query_description" {
  description = "Description of the orphaned storage accounts query."
  type        = string
  default     = "Finds storage accounts that may be unused or orphaned."
}

variable "orphaned_storage_accounts_query" {
  description = "Custom KQL query for orphaned storage accounts. If null, uses default."
  type        = string
  default     = null
}
