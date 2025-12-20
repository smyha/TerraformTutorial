# ============================================================================
# Azure FinOps Cost Export Module - Variables
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group to create the Storage Account in (only used if create_storage_account is true)."
  type        = string
  default     = null
}

variable "resource_group_id" {
  description = "ID of the resource group to export costs for. Format: /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account for exports (must be globally unique, 3-24 characters, alphanumeric). Only used if create_storage_account is true."
  type        = string
  default     = null
  validation {
    condition     = var.storage_account_name == null || (length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name)))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "create_storage_account" {
  description = "Whether to create a new Storage Account. Set to false to use an existing one."
  type        = bool
  default     = true
}

variable "existing_storage_account_id" {
  description = "ID of an existing Storage Account to use (required if create_storage_account is false). Can reference a storage account from a module output."
  type        = string
  default     = null
}

variable "existing_storage_account_name" {
  description = "Name of an existing Storage Account to use (required if create_storage_account is false). Used for container creation."
  type        = string
  default     = null
}

variable "existing_storage_account_resource_group_name" {
  description = "Resource group name of an existing Storage Account (optional, used for data source lookup)."
  type        = string
  default     = null
}

variable "storage_account_tier" {
  description = "Storage account tier. Options: 'Standard' or 'Premium'."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be 'Standard' or 'Premium'."
  }
}

variable "storage_account_kind" {
  description = "Storage account kind. Options: 'Storage', 'StorageV2', 'BlobStorage', 'FileStorage', 'BlockBlobStorage'."
  type        = string
  default     = "StorageV2"
  validation {
    condition     = contains(["Storage", "StorageV2", "BlobStorage", "FileStorage", "BlockBlobStorage"], var.storage_account_kind)
    error_message = "Storage account kind must be one of: Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage."
  }
}

variable "storage_account_replication_type" {
  description = "Storage account replication type. Options: 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', 'RAGZRS'."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "storage_min_tls_version" {
  description = "Minimum TLS version for the Storage Account. Options: 'TLS1_0', 'TLS1_1', 'TLS1_2'."
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.storage_min_tls_version)
    error_message = "Storage minimum TLS version must be TLS1_0, TLS1_1, or TLS1_2."
  }
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning for the Storage Account."
  type        = bool
  default     = true
}

variable "blob_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted blobs."
  type        = number
  default     = 7
  validation {
    condition     = var.blob_soft_delete_retention_days >= 1 && var.blob_soft_delete_retention_days <= 365
    error_message = "Blob soft delete retention days must be between 1 and 365."
  }
}

variable "storage_network_rules" {
  description = "Network rules for the Storage Account. If null, allows all traffic."
  type = object({
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
    bypass                     = optional(list(string), ["AzureServices"])
  })
  default = null
}

variable "container_name" {
  description = "Name of the storage container for cost exports."
  type        = string
  default     = "cost-exports"
  validation {
    condition     = length(var.container_name) >= 3 && length(var.container_name) <= 63 && can(regex("^[a-z0-9-]+$", var.container_name))
    error_message = "Container name must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}

variable "container_access_type" {
  description = "Access type for the storage container. Options: 'private', 'blob', 'container'."
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type must be 'private', 'blob', or 'container'."
  }
}

variable "export_name" {
  description = "Name of the cost export configuration."
  type        = string
  default     = "daily-cost-export"
}

variable "recurrence_type" {
  description = "Recurrence type for the export. Options: 'Daily', 'Weekly', 'Monthly'."
  type        = string
  default     = "Daily"
  validation {
    condition     = contains(["Daily", "Weekly", "Monthly"], var.recurrence_type)
    error_message = "Recurrence type must be 'Daily', 'Weekly', or 'Monthly'."
  }
}

variable "recurrence_period_start_date" {
  description = "Start date for the export recurrence period in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ). If null, uses current date."
  type        = string
  default     = null
}

variable "recurrence_period_end_date" {
  description = "End date for the export recurrence period in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ). If null, calculates based on recurrence_period_years."
  type        = string
  default     = null
}

variable "recurrence_period_years" {
  description = "Number of years for the export recurrence period (used if recurrence_period_end_date is null)."
  type        = number
  default     = 1
  validation {
    condition     = var.recurrence_period_years > 0 && var.recurrence_period_years <= 10
    error_message = "Recurrence period years must be between 1 and 10."
  }
}

variable "root_folder_path" {
  description = "Root folder path in the storage container for cost export files."
  type        = string
  default     = "costs"
}

variable "query_type" {
  description = "Type of cost query. Options: 'ActualCost', 'AmortizedCost', 'Usage'."
  type        = string
  default     = "ActualCost"
  validation {
    condition     = contains(["ActualCost", "AmortizedCost", "Usage"], var.query_type)
    error_message = "Query type must be 'ActualCost', 'AmortizedCost', or 'Usage'."
  }
}

variable "query_time_frame" {
  description = "Time frame for the cost query. Options: 'MonthToDate', 'BillingMonthToDate', 'TheLastMonth', 'TheLastBillingMonth', 'WeekToDate', 'Custom'."
  type        = string
  default     = "WeekToDate"
  validation {
    condition     = contains(["MonthToDate", "BillingMonthToDate", "TheLastMonth", "TheLastBillingMonth", "WeekToDate", "Custom"], var.query_time_frame)
    error_message = "Query time frame must be one of the valid options."
  }
}

variable "export_enabled" {
  description = "Whether the cost export is enabled."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod) for tagging and resource naming."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
