# Terraform Implementation Guides for Azure Monitor

This directory contains comprehensive guides for implementing Azure Monitor services using Terraform.

## Documentation Structure

1. **[01-log-analytics-workspace.md](./01-log-analytics-workspace.md)**
   - Creating Log Analytics workspaces
   - Workspace configuration
   - Data retention policies

2. **[02-diagnostic-settings.md](./02-diagnostic-settings.md)**
   - Configuring diagnostic settings
   - Resource log collection
   - Metric collection

3. **[03-metric-alerts.md](./03-metric-alerts.md)**
   - Creating metric alerts
   - Alert rules configuration
   - Action groups

4. **[04-log-alerts.md](./04-log-alerts.md)**
   - Creating log alerts
   - KQL query-based alerts
   - Scheduled alert rules

5. **[05-action-groups.md](./05-action-groups.md)**
   - Configuring action groups
   - Notification channels
   - Automated actions

6. **[06-monitor-module.md](./06-monitor-module.md)**
   - Using the Monitor module
   - Module configuration examples
   - Best practices

## Quick Start

### Basic Log Analytics Workspace

```hcl
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```

### Diagnostic Settings

```hcl
resource "azurerm_monitor_diagnostic_setting" "example" {
  name               = "diagnostics"
  target_resource_id = azurerm_virtual_network.main.id
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

### Metric Alert

```hcl
resource "azurerm_monitor_metric_alert" "example" {
  name                = "cpu-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_virtual_machine.main.id]
  description         = "Alert when CPU exceeds 80%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

## Best Practices

1. **Workspace Design**: Use centralized workspaces for better management
2. **Retention Policies**: Configure appropriate retention based on compliance needs
3. **Alert Thresholds**: Set realistic thresholds to avoid alert fatigue
4. **Cost Management**: Monitor data ingestion to control costs
5. **Security**: Use RBAC to control access to monitoring data

