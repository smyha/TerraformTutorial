# Azure Virtual Network Manager Module

This Terraform module creates and manages Azure Virtual Network Manager (AVNM) infrastructure, providing centralized network governance across multiple subscriptions and regions.

## Features

- **Network Manager Instance**: Centralized management service with flexible scope (Management Group or Subscription level)
- **Optional Resource Group**: Automatically creates a resource group if not provided
- **Network Groups**: Logical containers for VNets (static or dynamic membership via Azure Policy)
- **Connectivity Configuration**: Hub-and-spoke or mesh topologies with hub gateway support
- **Security Admin Rules**: Organization-level security policies that override NSG rules
- **Routing Configuration**: Centralized route table management with routing rules (next-hop to firewall, VPN, etc.)
- **Configuration Deployment**: Deploy configurations to specific regions

## Architecture

```
Network Manager Instance
├── Network Groups
│   ├── Static Membership VNets
│   └── Dynamic Membership (via Azure Policy)
├── Connectivity Configuration
│   ├── Hub-and-Spoke Topology
│   └── Mesh Topology
├── Security Admin Rules
└── Routing Configuration
```

## Usage

### Example 1: Network Manager with Management Group Scope (Enterprise-wide)

This example shows how to create a Network Manager with Management Group scope for enterprise-wide governance:

```hcl
module "network_manager_enterprise" {
  source = "./modules/virtual-network-manager"

  # Resource group will be created automatically if resource_group_name is empty
  resource_group_name    = ""  # Leave empty to auto-create
  project_name            = "enterprise"
  application_name        = "network-manager"
  environment             = "prod"
  location                = "eastus"
  network_manager_name    = "nwm-enterprise"

  # Management Group scope for enterprise-wide governance
  scope_management_group_ids = ["/providers/Microsoft.Management/managementGroups/Enterprise"]
  scope_accesses             = ["Connectivity", "SecurityAdmin", "Routing"]

  # Network Groups
  network_groups = {
    "production-vnets" = {
      description            = "Production virtual networks"
      static_member_vnet_ids = [
        "/subscriptions/xxx/resourceGroups/rg-prod/providers/Microsoft.Network/virtualNetworks/vnet-prod-1",
        "/subscriptions/xxx/resourceGroups/rg-prod/providers/Microsoft.Network/virtualNetworks/vnet-prod-2"
      ]
    }
  }

  # ... rest of configuration
}
```

### Example 2: Network Manager with Subscription Scope and Auto-created Resource Group

```hcl
module "network_manager" {
  source = "./modules/virtual-network-manager"

  # Resource group will be created automatically
  resource_group_name    = ""  # Auto-create resource group
  project_name            = "myproject"
  application_name        = "vnm"
  environment             = "prod"
  location                = "eastus"
  network_manager_name    = "nwm-enterprise"
  
  # Subscription scope
  scope_subscription_ids = ["subscription-id-1", "subscription-id-2"]
  scope_accesses        = ["Connectivity", "SecurityAdmin", "Routing"]

  # Network Groups
  network_groups = {
    "production-vnets" = {
      description            = "Production virtual networks"
      static_member_vnet_ids = [
        "/subscriptions/xxx/resourceGroups/rg-prod/providers/Microsoft.Network/virtualNetworks/vnet-prod-1",
        "/subscriptions/xxx/resourceGroups/rg-prod/providers/Microsoft.Network/virtualNetworks/vnet-prod-2"
      ]
    }
    "development-vnets" = {
      description            = "Development virtual networks"
      static_member_vnet_ids = [
        "/subscriptions/xxx/resourceGroups/rg-dev/providers/Microsoft.Network/virtualNetworks/vnet-dev-1"
      ]
    }
  }

  # Connectivity Configuration - Hub-and-Spoke with Hub Gateway
  connectivity_configurations = {
    "hub-spoke-prod" = {
      topology                        = "HubAndSpoke"
      network_group_names            = ["production-vnets"]
      group_connectivity              = "None"  # Spokes don't connect to each other
      use_hub_gateway                 = true    # Spokes can use hub's VPN/ExpressRoute gateway
      delete_existing_peering_enabled = false
      description                    = "Hub-and-spoke topology for production"
      hub = {
        resource_id   = "/subscriptions/xxx/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
        resource_type = "Microsoft.Network/virtualNetworks"
      }
    }
  }

  # Security Admin Configuration
  security_admin_configurations = {
    "security-prod" = {
      network_group_names = ["production-vnets"]
      description         = "Security admin rules for production"
    }
  }

  # Security Admin Rule Collections
  security_admin_rule_collections = {
    "deny-internet-prod" = {
      security_admin_configuration_name = "security-prod"
      network_group_names               = ["production-vnets"]
      description                       = "Deny internet traffic for production"
    }
  }

  # Security Admin Rules
  security_admin_rules = {
    "deny-all-internet-inbound" = {
      rule_collection_name            = "deny-internet-prod"
      priority                        = 100
      direction                       = "Inbound"
      access                          = "Deny"
      protocol                        = "Any"
      source_address_prefix_type      = "ServiceTag"
      source_address_prefix           = "Internet"
      destination_address_prefix_type = "IPPrefix"
      destination_address_prefix      = "0.0.0.0/0"
      description                     = "Deny all inbound internet traffic"
    }
    "allow-internal-vnet" = {
      rule_collection_name            = "deny-internet-prod"
      priority                        = 200
      direction                       = "Inbound"
      access                          = "Allow"
      protocol                        = "Any"
      source_address_prefix_type      = "ServiceTag"
      source_address_prefix           = "VirtualNetwork"
      destination_address_prefix_type = "IPPrefix"
      destination_address_prefix      = "0.0.0.0/0"
      description                     = "Allow internal VNet traffic"
    }
  }

  # Routing Configuration - Force traffic through Azure Firewall
  routing_configurations = {
    "routing-prod" = {
      network_group_names = ["production-vnets"]
      description         = "Routing configuration for production VNets"
    }
  }

  # Routing Rule Collections
  routing_rule_collections = {
    "firewall-routing" = {
      routing_configuration_name = "routing-prod"
      network_group_names        = ["production-vnets"]
      description                = "Route all internet traffic through Azure Firewall"
    }
  }

  # Routing Rules - Next-hop to Azure Firewall
  routing_rules = {
    "next-hop-firewall" = {
      rule_collection_name = "firewall-routing"
      description          = "Route all internet traffic (0.0.0.0/0) through Azure Firewall"
      destination_type     = "AddressPrefix"
      destination_address  = "0.0.0.0/0"
      next_hop_type        = "VirtualAppliance"
      next_hop_address     = "10.0.1.4"  # Azure Firewall private IP
    }
    "route-azure-services" = {
      rule_collection_name = "firewall-routing"
      description          = "Route Azure services through firewall"
      destination_type     = "ServiceTag"
      destination_address  = "AzureKeyVault"
      next_hop_type        = "VirtualAppliance"
      next_hop_address     = "10.0.1.4"
    }
  }

  # Deploy configurations to regions
  deployments = {
    "deploy-eastus" = {
      location          = "eastus"
      scope_access      = "Connectivity"
      configuration_ids = [module.network_manager.connectivity_configuration_ids["hub-spoke-prod"]]
    }
    "deploy-security-eastus" = {
      location          = "eastus"
      scope_access      = "SecurityAdmin"
      configuration_ids = [module.network_manager.security_admin_configuration_ids["security-prod"]]
    }
    "deploy-routing-eastus" = {
      location          = "eastus"
      scope_access      = "Routing"
      configuration_ids = [module.network_manager.routing_configuration_ids["routing-prod"]]
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Example 3: Complete Example with Existing Resource Group

```hcl
module "network_manager" {
  source = "./modules/virtual-network-manager"

  # Use existing resource group
  resource_group_name    = "rg-network-management"
  location               = "eastus"
  network_manager_name   = "nwm-enterprise"
  scope_subscription_ids = ["subscription-id-1", "subscription-id-2"]
  scope_accesses         = ["Connectivity", "SecurityAdmin", "Routing"]

### Example 4: Mesh Topology with Direct Connectivity

```hcl
module "network_manager_mesh" {
  source = "./modules/virtual-network-manager"

  resource_group_name    = "rg-network-management"
  location               = "eastus"
  network_manager_name   = "nwm-mesh"
  scope_subscription_ids = ["subscription-id-1"]

  network_groups = {
    "mesh-vnets" = {
      description            = "VNets for mesh topology"
      static_member_vnet_ids = [
        "/subscriptions/xxx/resourceGroups/rg-vnets/providers/Microsoft.Network/virtualNetworks/vnet-1",
        "/subscriptions/xxx/resourceGroups/rg-vnets/providers/Microsoft.Network/virtualNetworks/vnet-2",
        "/subscriptions/xxx/resourceGroups/rg-vnets/providers/Microsoft.Network/virtualNetworks/vnet-3"
      ]
    }
  }

  connectivity_configurations = {
    "mesh-config" = {
      topology                        = "Mesh"
      network_group_names            = ["mesh-vnets"]
      group_connectivity              = "DirectlyConnected"  # VNets can communicate directly
      delete_existing_peering_enabled = false
      description                    = "Full mesh connectivity between VNets"
    }
  }

  deployments = {
    "deploy-mesh-eastus" = {
      location          = "eastus"
      scope_access      = "Connectivity"
      configuration_ids = [module.network_manager_mesh.connectivity_configuration_ids["mesh-config"]]
    }
  }
}
```

### Example 5: Routing Rules - Next-Hop to Firewall

This example shows how to configure routing rules to force traffic through Azure Firewall:

```hcl
module "network_manager_with_routing" {
  source = "./modules/virtual-network-manager"

  resource_group_name    = "rg-network-management"
  location               = "eastus"
  network_manager_name   = "nwm-routing"
  scope_subscription_ids = ["subscription-id-1"]
  scope_accesses         = ["Routing"]

  network_groups = {
    "spoke-vnets" = {
      description            = "Spoke VNets that need firewall routing"
      static_member_vnet_ids = [
        "/subscriptions/xxx/resourceGroups/rg-spokes/providers/Microsoft.Network/virtualNetworks/vnet-spoke-1"
      ]
    }
  }

  # Routing Configuration
  routing_configurations = {
    "firewall-routing" = {
      network_group_names = ["spoke-vnets"]
      description         = "Route traffic through Azure Firewall"
    }
  }

  # Routing Rule Collections
  routing_rule_collections = {
    "internet-traffic" = {
      routing_configuration_name = "firewall-routing"
      network_group_names        = ["spoke-vnets"]
      description                = "Internet traffic routing rules"
    }
  }

  # Routing Rules
  routing_rules = {
    # Route all internet traffic through firewall
    "route-internet-to-firewall" = {
      rule_collection_name = "internet-traffic"
      description          = "Route all internet traffic (0.0.0.0/0) through Azure Firewall"
      destination_type     = "AddressPrefix"
      destination_address  = "0.0.0.0/0"
      next_hop_type        = "VirtualAppliance"
      next_hop_address     = "10.0.1.4"  # Azure Firewall private IP address
    }
    # Route specific Azure service through firewall
    "route-azure-storage" = {
      rule_collection_name = "internet-traffic"
      description          = "Route Azure Storage traffic through firewall"
      destination_type     = "ServiceTag"
      destination_address  = "Storage"
      next_hop_type        = "VirtualAppliance"
      next_hop_address     = "10.0.1.4"
    }
  }

  # Deploy routing configuration
  deployments = {
    "deploy-routing-eastus" = {
      location          = "eastus"
      scope_access      = "Routing"
      configuration_ids = [module.network_manager_with_routing.routing_configuration_ids["firewall-routing"]]
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource (optional) |
| [azurerm_network_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager) | resource |
| [azurerm_network_manager_network_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_network_group) | resource |
| [azurerm_network_manager_static_member](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_static_member) | resource |
| [azurerm_network_manager_connectivity_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_connectivity_configuration) | resource |
| [azurerm_network_manager_security_admin_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_security_admin_configuration) | resource |
| [azurerm_network_manager_admin_rule_collection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_admin_rule_collection) | resource |
| [azurerm_network_manager_admin_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_admin_rule) | resource |
| [azurerm_network_manager_routing_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_routing_configuration) | resource |
| [azurerm_network_manager_routing_rule_collection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_routing_rule_collection) | resource |
| [azurerm_network_manager_routing_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_routing_rule) | resource |
| [azurerm_network_manager_deployment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_deployment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group. Leave empty to auto-create | `string` | `""` | no |
| project_name | Project name for resource naming (required if resource_group_name is empty) | `string` | `""` | no |
| application_name | Application name for resource naming | `string` | `""` | no |
| environment | Environment name (e.g., 'dev', 'staging', 'prod') | `string` | `""` | no |
| location | Azure region | `string` | n/a | yes |
| network_manager_name | Name of the Network Manager instance | `string` | n/a | yes |
| scope_management_group_ids | List of Management Group IDs (enterprise-wide governance) | `list(string)` | `null` | no |
| scope_subscription_ids | List of subscription IDs (subscription-specific management) | `list(string)` | `null` | no |
| scope_accesses | Scope accesses (Connectivity, SecurityAdmin, Routing) | `list(string)` | `["Connectivity", "SecurityAdmin", "Routing"]` | no |
| description | Description of the Network Manager | `string` | `"Azure Virtual Network Manager for centralized network governance"` | no |
| tags | Map of tags | `map(string)` | `{}` | no |
| network_groups | Map of network groups | `map(object)` | `{}` | no |
| connectivity_configurations | Map of connectivity configurations | `map(object)` | `{}` | no |
| security_admin_configurations | Map of security admin configurations | `map(object)` | `{}` | no |
| security_admin_rule_collections | Map of security admin rule collections | `map(object)` | `{}` | no |
| security_admin_rules | Map of security admin rules | `map(object)` | `{}` | no |
| routing_configurations | Map of routing configurations | `map(object)` | `{}` | no |
| routing_rule_collections | Map of routing rule collections | `map(object)` | `{}` | no |
| routing_rules | Map of routing rules | `map(object)` | `{}` | no |
| deployments | Map of configuration deployments | `map(object)` | `{}` | no |

**Note**: At least one of `scope_management_group_ids` or `scope_subscription_ids` must be provided.

## Outputs

| Name | Description |
|------|-------------|
| network_manager_id | ID of the Network Manager instance |
| network_manager_name | Name of the Network Manager instance |
| resource_group_name | Name of the resource group (created or existing) |
| resource_group_id | ID of the resource group (created or existing) |
| network_group_ids | Map of network group IDs |
| connectivity_configuration_ids | Map of connectivity configuration IDs |
| security_admin_configuration_ids | Map of security admin configuration IDs |
| routing_configuration_ids | Map of routing configuration IDs |
| routing_rule_collection_ids | Map of routing rule collection IDs |
| routing_rule_ids | Map of routing rule IDs |
| admin_rule_collection_ids | Map of security admin rule collection IDs |
| admin_rule_ids | Map of security admin rule IDs |
| deployment_ids | Map of deployment IDs |
| network_group_details | Detailed information about network groups |
| connectivity_configuration_details | Detailed information about connectivity configurations |

## Important Notes

1. **Resource Group**: If `resource_group_name` is empty, a resource group will be automatically created using `project_name`, `application_name`, and `environment` variables.

2. **Scope Configuration**: At least one of `scope_management_group_ids` or `scope_subscription_ids` must be provided. Management Group scope is ideal for enterprise-wide governance, while Subscription scope is better for subscription-specific management.

3. **Configuration Deployment**: Configurations do not take effect until they are deployed to regions containing your target network resources. Always create deployments after creating configurations.

4. **Dynamic Membership**: Dynamic membership via Azure Policy is not directly supported in this module. You need to configure Azure Policy separately to enable dynamic membership for network groups.

5. **Hub Configuration**: Hub configuration is required for hub-and-spoke topology. The hub VNet must exist before creating the connectivity configuration.

6. **Hub Gateway**: When `use_hub_gateway` is set to `true`, spoke VNets can use the hub's VPN or ExpressRoute gateway for on-premises connectivity.

7. **Security Admin Rules**: Security Admin Rules are evaluated before NSG rules. They have the highest priority in the rule evaluation order and cannot be overridden by NSG rules.

8. **Routing Rules**: Routing rules allow you to force traffic through specific next-hops (e.g., Azure Firewall). Common use cases include routing all internet traffic (0.0.0.0/0) through a firewall.

9. **Scope Access**: Ensure the `scope_accesses` match the types of configurations you plan to create (Connectivity, SecurityAdmin, Routing).

## Best Practices

1. **Resource Group Management**: Use existing resource groups for production environments. Auto-create resource groups only for development/testing.

2. **Scope Selection**: 
   - Use Management Group scope for enterprise-wide governance across multiple subscriptions
   - Use Subscription scope for subscription-specific management

3. **Phased Deployment**: Deploy configurations to non-production environments first, then gradually roll out to production.

4. **Network Groups**: Use logical grouping by environment (production, staging, development), workload (web, database, application), or team/department.

5. **Security Rules**: Start restrictive (deny-all) then allow specific traffic. Document the business justification for each rule.

6. **Routing Rules**: 
   - Route all internet traffic (0.0.0.0/0) through Azure Firewall for security and compliance
   - Use Service Tags for Azure service traffic routing
   - Test routing rules in non-production first

7. **Hub Gateway**: Enable `use_hub_gateway` in hub-and-spoke topologies to allow spokes to use hub's VPN/ExpressRoute gateway for on-premises connectivity.

8. **Documentation**: Document network group purposes, rule justifications, and routing decisions.

9. **Monitoring**: Use Network Watcher to validate configurations after deployment and monitor network connectivity.

10. **Configuration Dependencies**: Always deploy configurations in the correct order: create configurations first, then deploy them to regions.

## References

- [Azure Virtual Network Manager Documentation](https://learn.microsoft.com/en-us/azure/virtual-network-manager/)
- [Terraform Azure Provider - Network Manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager)
- [Virtual Network Manager Best Practices](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-network-manager)

