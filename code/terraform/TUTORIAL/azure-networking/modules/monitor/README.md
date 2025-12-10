# Azure Monitor Module

This module creates Azure Monitor resources including Log Analytics workspaces, diagnostic settings, alerts, and action groups.

## Features

- **Log Analytics Workspace**: Centralized log data repository
- **Diagnostic Settings**: Collect logs and metrics from Azure resources
- **Metric Alerts**: Real-time threshold-based monitoring
- **Log Alerts**: Complex log query-based monitoring
- **Action Groups**: Notification and action configuration

## Usage

### Basic Example

```hcl
module "monitor" {
  source = "./modules/monitor"
  
  resource_group_name = "rg-monitoring"
  location            = "eastus"
  
  log_analytics_workspace_name = "law-monitoring"
  log_analytics_sku            = "PerGB2018"
  log_analytics_retention_in_days = 30
}
```

### Complete Example

```hcl
module "monitor" {
  source = "./modules/monitor"
  
  resource_group_name = "rg-monitoring"
  location            = "eastus"
  
  # Log Analytics Workspace
  log_analytics_workspace_name = "law-production"
  log_analytics_sku            = "PerGB2018"
  log_analytics_retention_in_days = 90
  
  # Diagnostic Settings
  diagnostic_settings = {
    vnet = {
      target_resource_id = azurerm_virtual_network.main.id
      logs = {
        VMProtectionAlerts = {
          enabled = true
        }
      }
      metrics = {
        AllMetrics = {
          enabled = true
        }
      }
    }
  }
  
  # Action Groups
  action_groups = {
    production = {
      short_name = "prod-alerts"
      email_receivers = [
        {
          name          = "admin"
          email_address = "admin@example.com"
        }
      ]
    }
  }
  
  # Metric Alerts
  metric_alerts = {
    cpu_alert = {
      description = "Alert when CPU exceeds 80%"
      scopes      = [azurerm_virtual_machine.main.id]
      criteria = {
        metric_namespace = "Microsoft.Compute/virtualMachines"
        metric_name      = "Percentage CPU"
        aggregation      = "Average"
        operator         = "GreaterThan"
        threshold        = 80
      }
      action_group_name = "production"
    }
  }
  
  # Log Alerts
  log_alerts = {
    error_alert = {
      description = "Alert on error count"
      query       = "Event | where EventLevelName == 'Error' | summarize count() by bin(TimeGenerated, 5m)"
      frequency   = 5
      time_window = 5
      trigger = {
        operator  = "GreaterThan"
        threshold = 10
      }
      action_group_name = "production"
    }
  }
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| create_log_analytics_workspace | Whether to create a Log Analytics workspace | `bool` | `true` | no |
| log_analytics_workspace_name | Name of the Log Analytics workspace | `string` | `null` | no |
| log_analytics_sku | SKU for Log Analytics workspace | `string` | `"PerGB2018"` | no |
| log_analytics_retention_in_days | Data retention in days | `number` | `30` | no |
| diagnostic_settings | Map of diagnostic settings | `map(object)` | `{}` | no |
| action_groups | Map of action groups | `map(object)` | `{}` | no |
| metric_alerts | Map of metric alerts | `map(object)` | `{}` | no |
| log_alerts | Map of log alerts | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_analytics_workspace_id | The ID of the Log Analytics workspace |
| log_analytics_workspace_name | The name of the Log Analytics workspace |
| action_group_ids | Map of action group names to their IDs |
| metric_alert_ids | Map of metric alert names to their IDs |
| log_alert_ids | Map of log alert names to their IDs |

## Best Practices

1. **Centralized Workspace**: Use a centralized Log Analytics workspace for better management
2. **Selective Logging**: Enable only necessary log categories to control costs
3. **Retention Configuration**: 
   - Configure retention at the Log Analytics workspace level using `log_analytics_retention_in_days`
   - For Storage Account destinations, use lifecycle management policies
   - Note: `retention_policy` blocks in diagnostic settings are deprecated
4. **Alert Thresholds**: Set realistic thresholds to avoid alert fatigue
5. **Action Groups**: Use action groups for consistent notification handling
6. **Cost Management**: Monitor data ingestion to control costs
7. **Security**: Use RBAC to control access to monitoring data

