# FinOps Resource Scheduler Module

This module automates the shutdown of resources to prevent waste.

## Value
*   **Plug the leak**: ~70% savings on Dev environments (168h vs 50h/week).
*   **Automated**: No manual intervention required.

## Usage

```hcl
module "scheduler" {
  source                  = "./modules/finops-resource-scheduler"
  resource_group_name     = "rg-dev-vms"
  location                = "eastus"
  automation_account_name = "aa-finops-prod"
}
```

## Inputs

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `automation_account_name` | `string` | Unique name | - |
| `resource_group_name` | `string` | Target RG | - |
