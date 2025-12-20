# FinOps Cost Export Module

This Terraform module configures automated export of Azure billing data to a Storage Account, enabling detailed cost analysis and historical tracking beyond Azure Portal limits.

## Features

- **Automated Daily/Weekly/Monthly Exports**: Configurable recurrence schedules
- **Flexible Storage Options**: Create new Storage Account or use existing one
- **Multiple Query Types**: ActualCost, AmortizedCost, or Usage data
- **Enterprise-Ready**: Supports integration with centralized storage modules
- **Data Protection**: Optional blob versioning and soft delete
- **Security**: Configurable network rules and TLS requirements

## Value Proposition

- **Data Democratization**: Raw billing data accessible for analysis in Power BI, Excel, or custom tools
- **Historical Retention**: Retains billing data beyond Azure Portal's 13-month limit
- **Cost Attribution**: Enables detailed cost allocation and showback/chargeback
- **Compliance**: Automated export ensures consistent data collection for audits

## Usage

### Basic Example: Create New Storage Account

```hcl
module "cost_export" {
  source = "./modules/finops-cost-export"

  resource_group_name  = "rg-finops-data"
  resource_group_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-finops-data"
  location             = "eastus"
  storage_account_name = "stfinopsexport001"
  environment          = "prod"

  tags = {
    CostCenter = "IT-Operations"
    Owner      = "FinOps-Team"
  }
}
```

### Advanced Example: Custom Configuration

```hcl
module "cost_export" {
  source = "./modules/finops-cost-export"

  resource_group_name  = "rg-finops-data"
  resource_group_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-finops-data"
  location             = "eastus"
  storage_account_name = "stfinopsexport001"
  
  # Storage Account Configuration
  storage_account_tier             = "Standard"
  storage_account_replication_type = "GRS"  # Geo-redundant for durability
  enable_blob_versioning           = true
  blob_soft_delete_retention_days  = 30
  
  # Export Configuration
  export_name      = "monthly-cost-export"
  recurrence_type  = "Monthly"
  query_type       = "AmortizedCost"
  query_time_frame = "TheLastMonth"
  root_folder_path = "monthly-reports"
  
  # Network Security
  storage_network_rules = {
    default_action = "Deny"
    ip_rules       = ["1.2.3.4/32"]  # Allow specific IPs
    bypass         = ["AzureServices"]
  }

  tags = {
    Environment = "prod"
    CostCenter  = "IT-Operations"
    Owner       = "FinOps-Team"
  }
}
```

### Using Existing Storage Account (Data Source)

```hcl
# Reference existing storage account via data source
data "azurerm_storage_account" "existing" {
  name                = "stsharedfinops001"
  resource_group_name = "rg-shared-services"
}

module "cost_export" {
  source = "./modules/finops-cost-export"

  resource_group_id = "/subscriptions/.../resourceGroups/rg-finops-data"
  location          = "eastus"
  
  # Use existing storage account
  create_storage_account         = false
  existing_storage_account_id    = data.azurerm_storage_account.existing.id
  existing_storage_account_name  = data.azurerm_storage_account.existing.name
}
```

### Using Storage Account from Module

```hcl
# If you have a centralized storage_account module
module "shared_storage" {
  source = "git::https://github.com/org/terraform-azurerm-storage-account.git?ref=v1.0.0"
  
  storage_account_name = "stsharedfinops001"
  resource_group_name  = "rg-shared-services"
  location             = "eastus"
  # ... other storage account configuration
}

module "cost_export" {
  source = "./modules/finops-cost-export"

  resource_group_id = "/subscriptions/.../resourceGroups/rg-finops-data"
  location          = "eastus"
  
  # Reference storage account from module
  create_storage_account         = false
  existing_storage_account_id    = module.shared_storage.storage_account_id
  existing_storage_account_name  = module.shared_storage.storage_account_name
}
```

## Inputs

| Name | Type | Description | Default | Required |
|------|------|-------------|---------|----------|
| `resource_group_id` | `string` | ID of the resource group to export costs for | - | yes |
| `location` | `string` | Azure region where resources will be created | - | yes |
| `resource_group_name` | `string` | Name of the resource group for Storage Account (if creating new) | `null` | no |
| `storage_account_name` | `string` | Name of the Storage Account (3-24 chars, alphanumeric) | `null` | no |
| `create_storage_account` | `bool` | Whether to create a new Storage Account | `true` | no |
| `existing_storage_account_id` | `string` | ID of existing Storage Account to use | `null` | no |
| `existing_storage_account_name` | `string` | Name of existing Storage Account to use | `null` | no |
| `storage_account_tier` | `string` | Storage account tier (Standard/Premium) | `"Standard"` | no |
| `storage_account_kind` | `string` | Storage account kind | `"StorageV2"` | no |
| `storage_account_replication_type` | `string` | Replication type (LRS/GRS/ZRS/etc.) | `"LRS"` | no |
| `storage_min_tls_version` | `string` | Minimum TLS version | `"TLS1_2"` | no |
| `enable_blob_versioning` | `bool` | Enable blob versioning | `true` | no |
| `blob_soft_delete_retention_days` | `number` | Days to retain soft-deleted blobs (1-365) | `7` | no |
| `storage_network_rules` | `object` | Network rules for Storage Account | `null` | no |
| `container_name` | `string` | Name of the storage container | `"cost-exports"` | no |
| `container_access_type` | `string` | Container access type (private/blob/container) | `"private"` | no |
| `export_name` | `string` | Name of the cost export configuration | `"daily-cost-export"` | no |
| `recurrence_type` | `string` | Export recurrence (Daily/Weekly/Monthly) | `"Daily"` | no |
| `recurrence_period_start_date` | `string` | Start date in ISO 8601 format | `null` | no |
| `recurrence_period_end_date` | `string` | End date in ISO 8601 format | `null` | no |
| `recurrence_period_years` | `number` | Years for export period (if end_date is null) | `1` | no |
| `root_folder_path` | `string` | Root folder path in container | `"costs"` | no |
| `query_type` | `string` | Cost query type (ActualCost/AmortizedCost/Usage) | `"ActualCost"` | no |
| `query_time_frame` | `string` | Time frame for cost query | `"WeekToDate"` | no |
| `export_enabled` | `bool` | Whether the export is enabled | `true` | no |
| `environment` | `string` | Environment name for tagging | `"prod"` | no |
| `tags` | `map(string)` | Map of tags to apply to resources | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `storage_account_id` | The ID of the Storage Account storing the exports |
| `storage_account_name` | The name of the Storage Account |
| `storage_account_primary_blob_endpoint` | The primary blob endpoint (if created) |
| `container_id` | The ID of the storage container |
| `container_name` | The name of the storage container |
| `export_id` | The ID of the Cost Management Export configuration |
| `export_name` | The name of the Cost Management Export |
| `export_storage_path` | Full storage path for cost exports (for Power BI, etc.) |

## Integration with Storage Modules

This module supports three approaches for Storage Account management:

### 1. Create New Storage Account (Default)
The module creates a new Storage Account with configurable security and compliance settings.

### 2. Use Existing Storage Account (Data Source)
Reference an existing Storage Account using a `data` block:

```hcl
data "azurerm_storage_account" "existing" {
  name                = "stsharedfinops001"
  resource_group_name = "rg-shared-services"
}
```

### 3. Use Storage Account from Module (Recommended for Enterprise)
Reference a Storage Account created by a centralized module:

```hcl
module "shared_storage" {
  source = "git::https://github.com/org/terraform-azurerm-storage-account.git"
  # ... configuration
}

module "cost_export" {
  source = "./modules/finops-cost-export"
  existing_storage_account_id = module.shared_storage.storage_account_id
  # ...
}
```

**Why use a centralized storage module?**
- **Compliance**: Centralized security policies and network rules
- **Cost Optimization**: Shared storage accounts reduce overhead
- **Governance**: Consistent naming, tagging, and lifecycle management
- **Maintenance**: Single source of truth for storage configuration

## Best Practices

1. **Use Geo-Redundant Storage (GRS)**: For production cost exports, use GRS or ZRS for durability
2. **Enable Blob Versioning**: Protects against accidental deletion or corruption
3. **Set Network Rules**: Restrict access to specific IPs or VNets for security
4. **Use Monthly Exports for Long-Term Analysis**: Daily exports are great for real-time monitoring, but monthly exports are sufficient for historical analysis
5. **Tag Resources**: Apply consistent tags for cost allocation and governance
6. **Centralize Storage**: In enterprise environments, use a shared storage account managed by a centralized module

## Accessing Exported Data

### Power BI
Connect Power BI to the Storage Account:
1. Get Data → Azure → Azure Blob Storage
2. Enter Storage Account name and container name
3. Use the `export_storage_path` output for the folder path

### Azure Storage Explorer
1. Connect to the Storage Account
2. Navigate to the container (default: `cost-exports`)
3. Browse to the root folder path (default: `costs`)

### Programmatic Access
Use Azure Storage SDKs or REST API to access exported CSV/Parquet files.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Related Modules

- `finops-budget-guardrails` - Automated budget alerts
- `finops-tagging-policy` - Enforce cost allocation tags
- `finops-storage-lifecycle` - Optimize storage costs

## License

This module is part of the Azure FinOps Terraform tutorial and is provided as-is for educational purposes.
