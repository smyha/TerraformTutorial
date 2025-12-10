# Using the Azure Monitor Module

This guide explains how to use the Azure Monitor Terraform module to set up comprehensive monitoring for your Azure resources.

## Overview

The Azure Monitor module provides a complete monitoring solution including:
- Log Analytics workspaces
- Diagnostic settings
- Metric alerts
- Log alerts
- Action groups

## Basic Usage

```hcl
module "monitor" {
  source = "./modules/monitor"
  
  resource_group_name = "rg-monitoring"
  location            = "eastus"
  
  log_analytics_workspace_name = "law-monitoring"
  sku                         = "PerGB2018"
  retention_in_days           = 30
}
```

## Complete Example

```hcl
module "monitor" {
  source = "./modules/monitor"
  
  resource_group_name = "rg-monitoring"
  location            = "eastus"
  
  # Log Analytics Workspace
  log_analytics_workspace_name = "law-production"
  sku                         = "PerGB2018"
  retention_in_days           = 90
  
  # Diagnostic Settings
  diagnostic_settings = {
    vnet = {
      target_resource_id = azurerm_virtual_network.main.id
      logs = {
        VMProtectionAlerts = {
          enabled = true
          retention_days = 30
        }
      }
      metrics = {
        AllMetrics = {
          enabled = true
          retention_days = 30
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
      name        = "vm-cpu-alert"
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
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Module Outputs

- `log_analytics_workspace_id`: ID of the Log Analytics workspace
- `log_analytics_workspace_name`: Name of the Log Analytics workspace
- `action_group_ids`: Map of action group names to IDs
- `metric_alert_ids`: Map of metric alert names to IDs

## Best Practices

1. **Centralized Workspace**: Use a centralized Log Analytics workspace
2. **Selective Logging**: Enable only necessary log categories
3. **Appropriate Thresholds**: Set realistic alert thresholds
4. **Cost Management**: Monitor data ingestion to control costs
5. **Testing**: Test all alert rules and action groups

