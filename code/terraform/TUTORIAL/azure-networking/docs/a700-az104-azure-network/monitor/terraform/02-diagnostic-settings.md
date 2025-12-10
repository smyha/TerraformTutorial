# Configuring Diagnostic Settings with Terraform

This guide explains how to configure diagnostic settings for Azure resources to send logs and metrics to Azure Monitor.

## Overview

Diagnostic settings enable you to collect resource logs and metrics from Azure resources and send them to:
- Log Analytics workspace
- Storage account
- Event Hub
- Partner solutions

## Basic Diagnostic Setting

### Minimal Configuration

```hcl
resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "diagnostics"
  target_resource_id        = azurerm_virtual_network.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}
```

## Diagnostic Setting Parameters

### Basic Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Name of the diagnostic setting |
| `target_resource_id` | string | Yes | ID of the resource to collect diagnostics from |
| `log_analytics_workspace_id` | string | No | Log Analytics workspace ID for logs |
| `storage_account_id` | string | No | Storage account ID for logs |
| `eventhub_name` | string | No | Event Hub name for streaming |

## Complete Example

```hcl
# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
}

# Diagnostic Setting for Virtual Network
resource "azurerm_monitor_diagnostic_setting" "vnet" {
  name                       = "vnet-diagnostics"
  target_resource_id         = azurerm_virtual_network.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  log {
    category = "VMProtectionAlerts"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

## Log Categories

Different resources support different log categories. Common categories include:

- **VMProtectionAlerts**: Virtual network protection alerts
- **NetworkSecurityGroupEvent**: NSG flow logs
- **NetworkSecurityGroupRuleCounter**: NSG rule counters
- **ApplicationGatewayAccessLog**: Application Gateway access logs
- **ApplicationGatewayPerformanceLog**: Application Gateway performance logs

## Metric Categories

- **AllMetrics**: All available metrics for the resource
- Resource-specific metric categories

## Advanced Configuration

### Multiple Destinations

```hcl
resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "diagnostics"
  target_resource_id         = azurerm_virtual_network.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  storage_account_id         = azurerm_storage_account.logs.id
  eventhub_name              = "diagnostics-events"
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.main.id

  log {
    category = "VMProtectionAlerts"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

### Retention Configuration

**Important Note**: The `retention_policy` block within `log` and `metric` blocks is deprecated. Retention is now managed differently:

- **For Log Analytics Workspace**: Configure retention at the workspace level using `retention_in_days`:
```hcl
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days    = 90  # Retention configured at workspace level
}
```

- **For Storage Account**: Use lifecycle management policies to control retention:
```hcl
resource "azurerm_storage_account" "logs" {
  name                = "storagelogs"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  account_tier        = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_management_policy" "logs" {
  storage_account_id = azurerm_storage_account.logs.id

  rule {
    name    = "delete-old-logs"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }
}
```

## Best Practices

1. **Centralized Workspace**: Use centralized Log Analytics workspaces
2. **Selective Logging**: Enable only necessary log categories
3. **Retention Configuration**: 
   - Configure retention at the Log Analytics workspace level (not in diagnostic settings)
   - Use lifecycle management policies for Storage Account destinations
   - Note: `retention_policy` blocks in diagnostic settings are deprecated
4. **Cost Management**: Monitor data ingestion to control costs
5. **Security**: Use RBAC to control access to diagnostic data

