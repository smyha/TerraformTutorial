# ============================================================================
# Azure FinOps K8s Cost Agent Module - Variables
# ============================================================================

variable "aks_cluster_id" {
  description = "The ID of the AKS cluster to install Kubecost on. Format: /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.ContainerService/managedClusters/{cluster-name}"
  type        = string
}

variable "enable_kubecost" {
  description = "Whether to enable Kubecost extension for cost visibility."
  type        = bool
  default     = true
}

variable "kubecost_extension_name" {
  description = "Name of the Kubecost extension."
  type        = string
  default     = "kubecost"
}

variable "kubecost_release_train" {
  description = "Release train for Kubecost. Options: 'Stable', 'Preview'."
  type        = string
  default     = "Stable"
  validation {
    condition     = contains(["Stable", "Preview"], var.kubecost_release_train)
    error_message = "Kubecost release train must be 'Stable' or 'Preview'."
  }
}

variable "kubecost_auto_upgrade_minor_version" {
  description = "Whether to automatically upgrade Kubecost minor versions."
  type        = bool
  default     = true
}

variable "kubecost_configuration_settings" {
  description = "Configuration settings for Kubecost extension."
  type        = map(string)
  default     = {}
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
