# K8s Cost Agent Module

This module enables cost visibility for Azure Kubernetes Service (AKS).

## Value
*   **Showback**: Allocate pod costs to teams/namespaces.
*   **Deep Dive**: See costs inside the "Black Box" of K8s.

## Usage

```hcl
module "kubecost" {
  source         = "./modules/k8s-cost-agent"
  aks_cluster_id = "/subscriptions/.../managedClusters/aks-01"
}
```

## Inputs

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `aks_cluster_id` | `string` | Target AKS Cluster ID | - |
