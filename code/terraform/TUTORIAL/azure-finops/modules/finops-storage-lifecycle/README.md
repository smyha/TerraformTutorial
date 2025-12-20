# FinOps Storage Lifecycle Module

This Terraform module configures Azure Storage Management Policies to automatically move data to cooler storage tiers and delete old data, optimizing storage costs.

## Features

- **Automatic Tiering**: Move data from Hot → Cool → Archive based on age
- **Configurable Rules**: Multiple rules for different containers/prefixes
- **Retention Policies**: Automatic deletion after specified retention periods
- **Snapshot & Version Management**: Lifecycle management for snapshots and versions
- **Enterprise-Ready**: Supports integration with centralized storage modules

## Value Proposition

- **Cost Optimization**: Automatically move cold data to cheaper storage tiers (Cool/Archive)
- **Compliance**: Automatic deletion of data after retention periods
- **Hands-Off Management**: Set it and forget it - policies run automatically
- **Significant Savings**: Can reduce storage costs by 50-90% for cold data

## Usage

### Basic Example: Default Lifecycle Policy

```hcl
module "storage_lifecycle" {
  source = "./modules/finops-storage-lifecycle"

  storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/stlogs001"
}
```

### Advanced Example: Multiple Rules

```hcl
module "storage_lifecycle" {
  source = "./modules/finops-storage-lifecycle"

  storage_account_id = "/subscriptions/.../storageAccounts/stlogs001"

  lifecycle_rules = [
    # Rule 1: Logs - Move to Cool after 7 days, Archive after 30 days, Delete after 90 days
    {
      name        = "logs-lifecycle"
      enabled     = true
      prefix_match = ["logs/"]
      blob_types  = ["blockBlob"]
      base_blob = {
        tier_to_cool_after_days_since_modification_greater_than    = 7
        tier_to_archive_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than           = 90
      }
    },
    # Rule 2: Backups - Move to Archive after 30 days, Delete after 365 days
    {
      name        = "backups-lifecycle"
      enabled     = true
      prefix_match = ["backups/"]
      blob_types  = ["blockBlob"]
      base_blob = {
        tier_to_archive_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than            = 365
      }
    },
    # Rule 3: All other data - Move to Cool after 30 days, Archive after 90 days
    {
      name        = "general-lifecycle"
      enabled     = true
      prefix_match = []  # Empty = all containers
      blob_types  = ["blockBlob"]
      base_blob = {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
      }
    }
  ]
}
```

### Using Storage Account from Module

```hcl
# If you have a centralized storage_account module
module "shared_storage" {
  source = "git::https://github.com/org/terraform-azurerm-storage-account.git"
  
  storage_account_name = "stsharedlogs001"
  resource_group_name  = "rg-shared-services"
  location             = "eastus"
  # ... other storage account configuration
}

module "storage_lifecycle" {
  source = "./modules/finops-storage-lifecycle"

  # Reference storage account from module
  storage_account_id = module.shared_storage.storage_account_id

  lifecycle_rules = [
    {
      name        = "logs-lifecycle"
      enabled     = true
      prefix_match = ["logs/"]
      blob_types  = ["blockBlob"]
      base_blob = {
        tier_to_cool_after_days_since_modification_greater_than    = 7
        tier_to_archive_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than           = 90
      }
    }
  ]
}
```

### Using Last Access Time (Requires Access Tracking)

```hcl
module "storage_lifecycle" {
  source = "./modules/finops-storage-lifecycle"

  storage_account_id = "/subscriptions/.../storageAccounts/stlogs001"

  lifecycle_rules = [
    {
      name        = "access-based-lifecycle"
      enabled     = true
      prefix_match = []
      blob_types  = ["blockBlob"]
      base_blob = {
        # Move to Cool if not accessed in 30 days
        tier_to_cool_after_days_since_last_access_time_greater_than = 30
        # Archive if not accessed in 90 days
        tier_to_archive_after_days_since_last_access_time_greater_than = 90
        # Delete if not accessed in 365 days
        delete_after_days_since_last_access_time_greater_than = 365
      }
    }
  ]
}
```

### Snapshot and Version Management

```hcl
module "storage_lifecycle" {
  source = "./modules/finops-storage-lifecycle"

  storage_account_id = "/subscriptions/.../storageAccounts/stbackups001"

  lifecycle_rules = [
    {
      name        = "snapshot-lifecycle"
      enabled     = true
      prefix_match = []
      blob_types  = ["blockBlob"]
      base_blob = {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
      snapshot = {
        # Delete snapshots older than 30 days
        delete_after_days_since_creation_greater_than = 30
        # Move snapshots to Cool after 7 days
        tier_to_cool_after_days_since_creation_greater_than = 7
      }
      version = {
        # Delete versions older than 90 days
        delete_after_days_since_creation_greater_than = 90
      }
    }
  ]
}
```

## Inputs

| Name | Type | Description | Default | Required |
|------|------|-------------|---------|----------|
| `storage_account_id` | `string` | ID of the Storage Account to apply policy to | - | yes |
| `lifecycle_rules` | `list(object)` | List of lifecycle rules | See defaults | no |
| `container_prefixes` | `list(string)` | [DEPRECATED] Use lifecycle_rules instead | `[]` | no |

### Lifecycle Rule Object

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Name of the rule |
| `enabled` | `bool` | Whether the rule is enabled |
| `prefix_match` | `list(string)` | Container prefixes to match (empty = all) |
| `blob_types` | `list(string)` | Blob types: ["blockBlob", "appendBlob"] |
| `base_blob` | `object` | Base blob lifecycle actions |
| `snapshot` | `object` | Snapshot lifecycle actions |
| `version` | `object` | Version lifecycle actions |

## Outputs

| Name | Description |
|------|-------------|
| `policy_id` | The ID of the Storage Management Policy |
| `storage_account_id` | The ID of the Storage Account |

## Integration with Storage Modules

This module supports three approaches for Storage Account management:

### 1. Direct Storage Account ID (Default)
Pass the storage account ID directly as a variable.

### 2. Use Existing Storage Account (Data Source)
Reference an existing Storage Account using a `data` block:

```hcl
data "azurerm_storage_account" "existing" {
  name                = "stlogs001"
  resource_group_name = "rg-storage"
}

module "storage_lifecycle" {
  source = "./modules/finops-storage-lifecycle"
  storage_account_id = data.azurerm_storage_account.existing.id
}
```

### 3. Use Storage Account from Module (Recommended for Enterprise)
Reference a Storage Account created by a centralized module:

```hcl
module "shared_storage" {
  source = "git::https://github.com/org/terraform-azurerm-storage-account.git"
  # ... configuration
}

module "storage_lifecycle" {
  source = "./modules/finops-storage-lifecycle"
  storage_account_id = module.shared_storage.storage_account_id
}
```

**Why use a centralized storage module?**
- **Compliance**: Centralized security policies and network rules
- **Cost Optimization**: Shared storage accounts reduce overhead
- **Governance**: Consistent naming, tagging, and lifecycle management
- **Maintenance**: Single source of truth for storage configuration

## Storage Tier Costs (Approximate)

| Tier | Cost per GB/Month | Use Case |
|------|------------------|----------|
| Hot | $0.018 | Frequently accessed data |
| Cool | $0.01 | Infrequently accessed data (30+ days) |
| Archive | $0.00099 | Rarely accessed data (180+ days) |

**Savings Example**: Moving 1TB of data from Hot to Archive saves ~$17/month (94% reduction).

## Best Practices

1. **Start Conservative**: Begin with longer retention periods and adjust based on actual usage
2. **Use Prefix Matching**: Apply different rules to different container prefixes (logs, backups, etc.)
3. **Enable Access Tracking**: Use last access time for more accurate lifecycle decisions (requires additional configuration)
4. **Test Before Production**: Test lifecycle policies on non-critical storage accounts first
5. **Monitor Costs**: Review storage costs monthly and adjust policies as needed
6. **Document Policies**: Document retention requirements for compliance and audit purposes

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Related Modules

- `finops-cost-export` - Export detailed billing data
- `finops-orphan-cleanup` - Remove unused storage resources
- `storage_account` - Centralized storage account management

## License

This module is part of the Azure FinOps Terraform tutorial and is provided as-is for educational purposes.
