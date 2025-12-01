# Azure Network Watcher Module

This module creates a Network Watcher instance with NSG Flow Logs and connection monitoring.

## Features

- Network topology visualization
- Connection monitoring
- Packet capture
- IP flow verify
- Next hop analysis
- VPN troubleshooting
- NSG Flow Logs
- Traffic Analytics

## Usage

```hcl
module "network_watcher" {
  source = "./modules/network-watcher"
  
  resource_group_name = "rg-example"
  location           = "eastus"
  
  network_watcher_name = "NetworkWatcher_eastus"
  enable_flow_logs     = true
  
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
      }
    }
  }
}
```

## Outputs

- `network_watcher_id`: The ID of the Network Watcher
- `network_watcher_name`: The name of the Network Watcher
- `flow_log_ids`: Map of flow log names to IDs

