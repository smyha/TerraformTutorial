# Azure Network Watcher Module

This module creates a Network Watcher instance with NSG Flow Logs and connection monitoring.

## Features

- **Network Topology**: Visualize network architecture
- **Connection Monitoring**: Test connectivity between endpoints
- **Packet Capture**: Capture network packets for analysis
- **IP Flow Verify**: Check if traffic is allowed or denied
- **Next Hop Analysis**: Determine packet routing paths
- **VPN Troubleshooting**: Diagnose VPN gateway issues
- **NSG Flow Logs**: Log IP traffic through NSGs
- **Traffic Analytics**: Rich visualizations of flow log data

## Usage

### Basic Example

```hcl
module "network_watcher" {
  source = "./modules/network-watcher"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  
  network_watcher_name = "NetworkWatcher_eastus"
}
```

### Complete Example with Flow Logs and Connection Monitors

```hcl
module "network_watcher" {
  source = "./modules/network-watcher"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  
  network_watcher_name = "NetworkWatcher_eastus"
  enable_flow_logs     = true
  
  # NSG Flow Logs
  flow_logs = {
    "nsg-web-flow-log" = {
      network_security_group_id = azurerm_network_security_group.web.id
      storage_account_id        = azurerm_storage_account.logs.id
      enabled                   = true
      retention_days            = 30
      version                   = 2
      traffic_analytics = {
        enabled               = true
        workspace_id          = azurerm_log_analytics_workspace.main.workspace_id
        workspace_region      = "eastus"
        workspace_resource_id = azurerm_log_analytics_workspace.main.id
        interval_in_minutes   = 60
      }
    }
  }
  
  # Connection Monitors
  connection_monitors = {
    "web-to-db" = {
      name  = "cm-web-to-db"
      notes = "Monitor connectivity from web to database"
      source = {
        virtual_machine_id = azurerm_virtual_machine.web.id
      }
      destination = {
        address = "10.0.3.10"
      }
      test_configurations = [
        {
          name                      = "tcp-test"
          protocol                  = "Tcp"
          test_frequency_in_seconds = 60
          preferred_ip_version      = "IPv4"
          tcp_configuration = {
            port                = 1433
            disable_trace_route = false
          }
        }
      ]
      enabled = true
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
| network_watcher_name | Name of the Network Watcher | `string` | `null` | no |
| enable_flow_logs | Enable NSG flow logs | `bool` | `false` | no |
| flow_logs | Map of NSG flow logs | `map(object)` | `{}` | no |
| connection_monitors | Map of connection monitors | `map(object)` | `{}` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

- `network_watcher_id`: The ID of the Network Watcher
- `network_watcher_name`: The name of the Network Watcher
- `flow_log_ids`: Map of flow log names to IDs
- `connection_monitor_ids`: Map of connection monitor names to IDs

## Best Practices

1. **Regional Deployment**: Deploy Network Watcher in each region where you have resources
2. **Flow Logs**: Enable Version 2 flow logs for enhanced features
3. **Traffic Analytics**: Enable Traffic Analytics for better insights
4. **Connection Monitors**: Monitor critical paths between applications
5. **Retention**: Configure appropriate retention based on compliance needs
6. **Cost Management**: Monitor storage costs for flow logs
7. **Security**: Use RBAC to control access to Network Watcher data

