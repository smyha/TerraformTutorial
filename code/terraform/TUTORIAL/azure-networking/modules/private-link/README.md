# Azure Private Link Module

This module creates Private Endpoints and Private Link Services for private connectivity to Azure services.

## Features

- Private Endpoints for Azure PaaS services
- Private Link Services for exposing your own services
- Automatic DNS integration
- No public exposure
- Traffic stays on Azure backbone

## Usage

```hcl
module "private_link" {
  source = "./modules/private-link"
  
  resource_group_name = "rg-example"
  location           = "eastus"
  
  # Private Endpoint for Storage Account
  private_endpoints = {
    "storage-endpoint" = {
      name      = "pe-storage"
      subnet_id = azurerm_subnet.private_endpoints.id
      private_service_connection = {
        name                           = "storage-connection"
        private_connection_resource_id = azurerm_storage_account.main.id
        subresource_names              = ["blob"]
        is_manual_connection           = false
      }
      private_dns_zone_group = {
        name                 = "storage-dns-zone-group"
        private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
      }
    }
  }
}
```

## Outputs

- `private_endpoint_ids`: Map of private endpoint names to IDs
- `private_endpoint_private_ip_addresses`: Map of private endpoint names to IP addresses
- `private_link_service_ids`: Map of private link service names to IDs
- `private_link_service_aliases`: Map of private link service names to aliases

