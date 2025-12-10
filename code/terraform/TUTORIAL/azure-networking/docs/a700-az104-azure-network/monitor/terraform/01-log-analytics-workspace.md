# Creating Log Analytics Workspaces with Terraform

This guide explains how to create and configure Log Analytics workspaces using Terraform.

## Overview

A Log Analytics workspace is a unique environment for Azure Monitor log data. Each workspace has its own data repository and configuration, but data can be combined from multiple workspaces.

## Basic Log Analytics Workspace

### Minimal Configuration

```hcl
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
}
```

## Log Analytics Workspace Parameters

### Basic Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Name of the Log Analytics workspace (must be globally unique) |
| `location` | string | Yes | Azure region for the workspace |
| `resource_group_name` | string | Yes | Name of the resource group |
| `sku` | string | No | Pricing tier (default: "PerGB2018") |
| `retention_in_days` | number | No | Data retention in days (30-730, or null for unlimited) |

### SKU Options

- **PerGB2018**: Pay-as-you-go pricing per GB ingested
- **CapacityReservation**: Reserved capacity pricing
- **Free**: Limited free tier (500 MB/day)

## Complete Example

```hcl
# Resource Group
resource "azurerm_resource_group" "monitoring" {
  name     = "rg-monitoring"
  location = "eastus"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-monitoring-prod"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Advanced Configuration

### Workspace with Daily Cap

```hcl
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 10  # Limit daily ingestion to 10 GB
}
```

### Workspace with Internet Ingestion Enabled

```hcl
resource "azurerm_log_analytics_workspace" "main" {
  name                       = "law-monitoring"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  sku                        = "PerGB2018"
  internet_ingestion_enabled = true  # Allow ingestion from internet
  internet_query_enabled      = true  # Allow queries from internet
}
```

## Best Practices

1. **Naming Convention**: Use descriptive names like `law-{environment}-{purpose}`
2. **Retention**: Configure retention based on compliance requirements
3. **SKU Selection**: Choose appropriate SKU based on data volume
4. **Daily Cap**: Set daily quota to control costs
5. **Tags**: Use tags for organization and cost tracking

