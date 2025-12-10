# Creating Log Alerts with Terraform

This guide explains how to create log alerts in Azure Monitor using Terraform.

## Overview

Log alerts are based on log query results and are evaluated on a schedule. They are ideal for complex conditions and large data volumes.

## Basic Log Alert

### Minimal Configuration

```hcl
resource "azurerm_monitor_scheduled_query_rules_alert" "example" {
  name                = "log-alert"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  description         = "Alert on error count"

  data_source_id = azurerm_log_analytics_workspace.main.id
  query          = "Event | where EventLevelName == 'Error' | summarize count() by bin(TimeGenerated, 5m)"
  frequency      = 5
  time_window    = 5
  severity       = 2

  trigger {
    operator  = "GreaterThan"
    threshold = 10
  }

  action {
    action_group = [azurerm_monitor_action_group.main.id]
  }
}
```

## Log Alert Parameters

### Basic Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Name of the log alert |
| `resource_group_name` | string | Yes | Resource group name |
| `location` | string | Yes | Azure region |
| `data_source_id` | string | Yes | Log Analytics workspace ID |
| `query` | string | Yes | KQL query to evaluate |
| `frequency` | number | Yes | Evaluation frequency in minutes |
| `time_window` | number | Yes | Time window in minutes |
| `severity` | number | No | Alert severity (0-4) |

## Complete Example

```hcl
# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
}

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

# Log Alert
resource "azurerm_monitor_scheduled_query_rules_alert" "errors" {
  name                = "error-alert"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  description         = "Alert when error count exceeds threshold"

  data_source_id = azurerm_log_analytics_workspace.main.id
  query          = <<-QUERY
    Event
    | where EventLevelName == 'Error'
    | summarize ErrorCount = count() by bin(TimeGenerated, 5m)
    | project ErrorCount
  QUERY
  
  frequency   = 5
  time_window = 5
  severity    = 2

  trigger {
    operator  = "GreaterThan"
    threshold = 10
  }

  action {
    action_group = [azurerm_monitor_action_group.main.id]
  }
}
```

## KQL Query Examples

### Error Count Query

```kql
Event
| where EventLevelName == 'Error'
| summarize ErrorCount = count() by bin(TimeGenerated, 5m)
| project ErrorCount
```

### Failed Login Attempts

```kql
SigninLogs
| where ResultType != "0"
| summarize FailedLogins = count() by bin(TimeGenerated, 5m)
| project FailedLogins
```

### High CPU Usage

```kql
Perf
| where CounterName == "% Processor Time"
| where CounterValue > 80
| summarize count() by bin(TimeGenerated, 5m)
```

## Advanced Configuration

### Multiple Metrics

```hcl
resource "azurerm_monitor_scheduled_query_rules_alert" "example" {
  name                = "multi-metric-alert"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  data_source_id = azurerm_log_analytics_workspace.main.id
  query          = <<-QUERY
    let threshold = 80;
    Perf
    | where CounterName == "% Processor Time"
    | summarize AvgCPU = avg(CounterValue) by bin(TimeGenerated, 5m)
    | where AvgCPU > threshold
    | project AvgCPU
  QUERY
  
  frequency   = 5
  time_window = 5

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group = [azurerm_monitor_action_group.main.id]
  }
}
```

## Best Practices

1. **Query Optimization**: Optimize KQL queries for performance
2. **Evaluation Frequency**: Balance between responsiveness and cost
3. **Time Windows**: Use appropriate time windows for your data
4. **Thresholds**: Set realistic thresholds based on historical data
5. **Testing**: Test queries in Log Analytics before creating alerts

