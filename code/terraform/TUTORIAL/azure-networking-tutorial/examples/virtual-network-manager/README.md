# Azure Virtual Network Manager Example

This example demonstrates how to use the Azure Virtual Network Manager module to create a complete network governance solution.

## What This Example Creates

- **Network Manager Instance**: Centralized network management with subscription scope
- **Network Groups**: Logical grouping of VNets (Production, Development, Shared Services)
- **Hub-and-Spoke Connectivity**: Connects spoke VNets to a central hub VNet
- **Security Admin Rules**: Organization-level security policies (deny internet inbound, allow internal)
- **Routing Rules**: Force traffic through Azure Firewall (next-hop routing)
- **Configuration Deployments**: Deploy configurations to specific regions

## Architecture

```
Network Manager Instance
├── Network Groups
│   ├── production-vnets
│   ├── development-vnets
│   └── shared-services-vnets
├── Connectivity Configurations
│   ├── hub-spoke-production (Hub-and-Spoke)
│   └── hub-spoke-development (Hub-and-Spoke)
├── Security Admin Configurations
│   ├── security-production
│   └── security-development
├── Security Admin Rules
│   ├── deny-all-internet-inbound-prod
│   └── allow-internal-vnet-prod
├── Routing Configuration
│   └── routing-production
└── Routing Rules
    ├── route-internet-to-firewall
    ├── route-azure-storage
    └── route-azure-keyvault
```

## Prerequisites

1. **Azure Subscription**: You need at least one Azure subscription
2. **VNets**: You need existing Virtual Networks to add to network groups (or create them first)
3. **Hub VNet**: For hub-and-spoke topology, you need a hub VNet
4. **Azure Firewall**: For routing rules, you need an Azure Firewall with a known private IP

## Configuration

### Step 1: Copy the example variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Update terraform.tfvars with your values

1. **Subscription IDs**: Update `scope_subscription_ids` with your actual subscription IDs
2. **VNet IDs**: Update `static_member_vnet_ids` in `network_groups` with your actual VNet resource IDs
3. **Hub VNet ID**: Update `hub.resource_id` in `connectivity_configurations` with your hub VNet resource ID
4. **Firewall IP**: Update `next_hop_address` in `routing_rules` with your Azure Firewall private IP address

### Alternative: Use environment variables

You can also set variables using environment variables:
```bash
export TF_VAR_network_manager_name="nwm-example"
export TF_VAR_location="eastus"
export TF_VAR_scope_subscription_ids='["subscription-id-1"]'
```

### Example VNet ID Format

```
/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}
```

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

### 4. Verify Deployments

After applying, verify that configurations are deployed:

```bash
# Check deployment status
terraform output deployment_ids
```

## Key Features Demonstrated

### 1. Subscription Scope

This example uses subscription scope. To use Management Group scope, uncomment the `network_manager_management_group` module in `main.tf`.

### 2. Hub-and-Spoke with Hub Gateway

The production connectivity configuration enables `use_hub_gateway = true`, allowing spoke VNets to use the hub's VPN/ExpressRoute gateway for on-premises connectivity.

### 3. Security Admin Rules

- **Deny Internet Inbound**: Blocks all inbound traffic from the Internet
- **Allow Internal VNet**: Allows traffic between VNets within the same network group

### 4. Routing Rules

- **Internet Traffic**: Routes all internet traffic (0.0.0.0/0) through Azure Firewall
- **Azure Services**: Routes Azure Storage and Key Vault traffic through firewall

## Outputs

The example provides outputs for:
- Network Manager ID and name
- Network Group IDs and details
- Connectivity Configuration IDs
- Security Admin Configuration IDs
- Routing Configuration IDs
- Routing Rule IDs
- Deployment IDs
- Summary of created resources

## Cleanup

To remove all created resources:

```bash
terraform destroy
```

## Notes

1. **VNet IDs**: Make sure the VNet IDs you provide actually exist before running this example
2. **Hub VNet**: The hub VNet must exist before creating the connectivity configuration
3. **Firewall IP**: The firewall private IP must be correct for routing rules to work
4. **Deployments**: Configurations don't take effect until deployed to regions
5. **Dynamic Membership**: This example uses static membership. For dynamic membership, configure Azure Policy separately

## Related Documentation

- [Module README](../../modules/virtual-network-manager/README.md)
- [Azure Virtual Network Manager Documentation](https://learn.microsoft.com/en-us/azure/virtual-network-manager/)
- [Terraform Azure Provider - Network Manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager)

