# ============================================================================
# Azure FinOps Resource Scheduler Module - Variables
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group to create the Automation Account in (only used if create_automation_account is true)."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

variable "automation_account_name" {
  description = "Name of the Automation Account to create (only used if create_automation_account is true)."
  type        = string
  default     = null
}

variable "create_automation_account" {
  description = "Whether to create a new Automation Account. Set to false to use an existing one."
  type        = bool
  default     = true
}

variable "existing_automation_account_name" {
  description = "Name of an existing Automation Account to use (required if create_automation_account is false). Can reference an automation account from a module output."
  type        = string
  default     = null
}

variable "existing_automation_account_resource_group_name" {
  description = "Resource group name of an existing Automation Account (required if create_automation_account is false)."
  type        = string
  default     = null
}

variable "automation_account_sku" {
  description = "SKU for the Automation Account. Options: 'Basic' or 'Free'."
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Free"], var.automation_account_sku)
    error_message = "Automation account SKU must be 'Basic' or 'Free'."
  }
}

variable "automation_public_network_access_enabled" {
  description = "Whether public network access is enabled for the Automation Account."
  type        = bool
  default     = true
}

variable "automation_identity_type" {
  description = "Type of identity for the Automation Account. Options: 'SystemAssigned', 'UserAssigned', 'SystemAssigned,UserAssigned'."
  type        = string
  default     = "SystemAssigned"
}

# Runbook Configuration
variable "runbook_type" {
  description = "Type of runbook. Options: 'PowerShell', 'PowerShellWorkflow', 'Python3', 'Graph', 'GraphPowerShellWorkflow'."
  type        = string
  default     = "PowerShell"
}

variable "runbook_log_verbose" {
  description = "Whether to log verbose output from runbooks."
  type        = bool
  default     = true
}

variable "runbook_log_progress" {
  description = "Whether to log progress from runbooks."
  type        = bool
  default     = true
}

variable "stop_runbook_name" {
  description = "Name of the stop VMs runbook."
  type        = string
  default     = "Stop-VMs-Schedule"
}

variable "stop_runbook_description" {
  description = "Description of the stop VMs runbook."
  type        = string
  default     = "Stops VMs with specific tags based on schedule"
}

variable "stop_runbook_content" {
  description = "Custom PowerShell content for the stop runbook. If null, uses default."
  type        = string
  default     = null
}

variable "create_start_runbook" {
  description = "Whether to create a start VMs runbook."
  type        = bool
  default     = true
}

variable "start_runbook_name" {
  description = "Name of the start VMs runbook."
  type        = string
  default     = "Start-VMs-Schedule"
}

variable "start_runbook_description" {
  description = "Description of the start VMs runbook."
  type        = string
  default     = "Starts VMs with specific tags based on schedule"
}

variable "start_runbook_content" {
  description = "Custom PowerShell content for the start runbook. If null, uses default."
  type        = string
  default     = null
}

# Schedule Configuration
variable "schedule_tag_name" {
  description = "Tag name used to identify VMs that should be scheduled (e.g., 'Schedule', 'AutoShutdown')."
  type        = string
  default     = "Schedule"
}

variable "schedule_tag_value" {
  description = "Tag value that identifies VMs to be scheduled (e.g., 'BusinessHours', 'Weekdays')."
  type        = string
  default     = "BusinessHours"
}

variable "stop_schedule_name" {
  description = "Name of the stop schedule."
  type        = string
  default     = "Stop-VMs-Daily"
}

variable "stop_schedule_frequency" {
  description = "Frequency of the stop schedule. Options: 'OneTime', 'Day', 'Hour', 'Week', 'Month'."
  type        = string
  default     = "Day"
}

variable "stop_schedule_interval" {
  description = "Interval for the stop schedule (e.g., 1 = every day, 2 = every other day)."
  type        = number
  default     = 1
}

variable "stop_schedule_time" {
  description = "Time for the stop schedule in HH:MM format (24-hour)."
  type        = string
  default     = "19:00"
}

variable "stop_schedule_start_time" {
  description = "Start time for the stop schedule in ISO 8601 format. If null, uses current date with stop_schedule_time."
  type        = string
  default     = null
}

variable "stop_schedule_description" {
  description = "Description of the stop schedule."
  type        = string
  default     = "Daily schedule to stop VMs"
}

variable "start_schedule_name" {
  description = "Name of the start schedule."
  type        = string
  default     = "Start-VMs-Daily"
}

variable "start_schedule_frequency" {
  description = "Frequency of the start schedule. Options: 'OneTime', 'Day', 'Hour', 'Week', 'Month'."
  type        = string
  default     = "Day"
}

variable "start_schedule_interval" {
  description = "Interval for the start schedule (e.g., 1 = every day, 2 = every other day)."
  type        = number
  default     = 1
}

variable "start_schedule_time" {
  description = "Time for the start schedule in HH:MM format (24-hour)."
  type        = string
  default     = "07:00"
}

variable "start_schedule_start_time" {
  description = "Start time for the start schedule in ISO 8601 format. If null, uses current date with start_schedule_time."
  type        = string
  default     = null
}

variable "start_schedule_description" {
  description = "Description of the start schedule."
  type        = string
  default     = "Daily schedule to start VMs"
}

variable "schedule_timezone" {
  description = "Timezone for schedules (e.g., 'UTC', 'Eastern Standard Time')."
  type        = string
  default     = "UTC"
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
