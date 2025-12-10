# Creating Metric Alerts with Terraform

This guide explains how to create metric alerts in Azure Monitor using Terraform.

## Overview

Metric alerts monitor metric values and trigger when conditions are met. They provide near real-time monitoring and are ideal for threshold-based scenarios.

## Basic Metric Alert

### Minimal Configuration

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
}
```

## Metric Alert Parameters

### Basic Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Name of the metric alert |
| `resource_group_name` | string | Yes | Resource group name |
| `scopes` | list(string) | Yes | List of resource IDs to monitor |
| `description` | string | No | Alert description |
| `enabled` | bool | No | Enable/disable alert (default: true) |
| `severity` | number | No | Alert severity (0-4, default: 3) |
| `frequency` | string | No | Evaluation frequency (default: "PT1M") |
| `window_size` | string | No | Time window for evaluation (default: "PT5M") |

## Complete Example

```hcl
# Action Group
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "alerts"

  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
  }
}

# Metric Alert
resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "vm-cpu-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_virtual_machine.main.id]
  description         = "Alert when CPU exceeds 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

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

## Alert Criteria

### Aggregation Types

- **Average**: Average value over the time window
- **Count**: Count of measurements
- **Minimum**: Minimum value
- **Maximum**: Maximum value
- **Total**: Sum of values

### Operators

- **Equals**: Exactly equal to threshold
- **NotEquals**: Not equal to threshold
- **GreaterThan**: Greater than threshold
- **GreaterThanOrEqual**: Greater than or equal to threshold
- **LessThan**: Less than threshold
- **LessThanOrEqual**: Less than or equal to threshold

## Advanced Configuration

### Multiple Criteria

```hcl
resource "azurerm_monitor_metric_alert" "example" {
  name                = "multi-criteria-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_virtual_machine.main.id]
  description         = "Alert when CPU > 80% AND Memory > 90%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1073741824  # 1 GB in bytes
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

### Dynamic Thresholds

```hcl
resource "azurerm_monitor_metric_alert" "example" {
  name                = "dynamic-threshold-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_virtual_machine.main.id]

  dynamic_criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    alert_sensitivity = "Medium"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

## Best Practices

1. **Threshold Selection**: Set realistic thresholds to avoid alert fatigue
2. **Evaluation Frequency**: Balance between responsiveness and cost
3. **Action Groups**: Use action groups for consistent notification handling
4. **Severity Levels**: Use appropriate severity levels (0-4)
5. **Testing**: Test alert rules before production deployment

