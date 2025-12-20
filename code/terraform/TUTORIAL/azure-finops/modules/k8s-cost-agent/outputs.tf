# ============================================================================
# Azure FinOps K8s Cost Agent Module - Outputs
# ============================================================================

output "kubecost_extension_id" {
  description = "The ID of the Kubecost extension (if enabled)."
  value       = var.enable_kubecost ? azurerm_kubernetes_cluster_extension.kubecost[0].id : null
}

output "kubecost_extension_name" {
  description = "The name of the Kubecost extension."
  value       = var.enable_kubecost ? azurerm_kubernetes_cluster_extension.kubecost[0].name : null
}

output "aks_cluster_id" {
  description = "The ID of the AKS cluster."
  value       = var.aks_cluster_id
}
