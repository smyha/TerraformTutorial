# Implementing Virtual Network Service Endpoints with Terraform

## Overview

Service endpoints provide secure, direct connectivity to Azure PaaS services over the Azure backbone network.

## Terraform Implementation

### Enable Service Endpoints on Subnet

```hcl
resource "azurerm_subnet" "main" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault"
  ]
}
```

### Service Endpoint with Policies

```hcl
resource "azurerm_subnet" "main" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]

  service_endpoint_policy_ids = [
    azurerm_subnet_service_endpoint_storage_policy.main.id
  ]
}
```

## Available Service Endpoints

- Microsoft.Storage
- Microsoft.Sql
- Microsoft.KeyVault
- Microsoft.ServiceBus
- Microsoft.CosmosDB
- Microsoft.Web
- Microsoft.AzureActiveDirectory

## Additional Resources

- [Service Endpoints Overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Terraform azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)


