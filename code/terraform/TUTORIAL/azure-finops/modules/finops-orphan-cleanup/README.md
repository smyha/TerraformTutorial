# FinOps Orphan Cleanup Module

This module detects and (optionally) removes unused resources.

## Value
*   **Hygiene**: Keeps the environment clean.
*   **Immediate Savings**: Unattached disks and IPs cost money every hour.

## Usage

```hcl
module "orphans" {
  source            = "./modules/finops-orphan-cleanup"
  resource_group_id = "/subscriptions/.../resourceGroups/rg-finops"
}
```

## Inputs

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `resource_group_id` | `string` | Where to save the Resource Graph queries | - |
