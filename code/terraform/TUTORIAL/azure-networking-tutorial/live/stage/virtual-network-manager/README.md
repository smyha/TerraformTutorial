# Virtual Network Manager - Terragrunt Example (Stage Environment)

This directory contains a Terragrunt configuration for deploying Azure Virtual Network Manager in the stage environment.

## Overview

This example demonstrates how to use the Virtual Network Manager module with Terragrunt for:
- Centralized network governance
- Hub-and-spoke connectivity
- Security admin rules
- Routing rules (next-hop to firewall)

## Prerequisites

1. **Terragrunt installed**: Version >= 0.50.0
2. **Azure credentials**: Configured via Azure CLI or environment variables
3. **Dependencies**: 
   - Hub VNet (for hub-and-spoke topology)
   - Azure Firewall (for routing rules)

## Configuration

### Option 1: Using terraform.tfvars (Recommended)

1. **Copy the example file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Update terraform.tfvars** with your values:
   - Subscription IDs: Update `scope_subscription_ids`
   - VNet IDs: Add your VNet resource IDs to `network_groups.static_member_vnet_ids`
   - Other configuration as needed

### Option 2: Using Environment Variables

Set environment variables:
```bash
export TF_VAR_network_manager_name="nwm-stage"
export TF_VAR_location="eastus"
export TF_VAR_resource_group_name="rg-network-management-stage"
export TF_VAR_scope_subscription_ids='["subscription-id-1","subscription-id-2"]'
```

### Remote State Configuration

Set required environment variables for remote state:
```bash
export TF_STATE_STORAGE_ACCOUNT_NAME=myterraformstate
export TF_STATE_RESOURCE_GROUP_NAME=rg-terraform-state
export TF_STATE_CONTAINER_NAME=terraform-state
export TF_STATE_KEY=stage
```

## Usage

### 1. Navigate to this directory

```bash
cd live/stage/virtual-network-manager
```

### 2. Initialize Terragrunt

```bash
terragrunt init
```

### 3. Plan the deployment

```bash
terragrunt plan
```

### 4. Apply the configuration

```bash
terragrunt apply
```

### 5. Deploy configurations (two-step process)

**Step 1**: First apply creates the configurations. Get the configuration IDs:

```bash
terragrunt output connectivity_configuration_ids
terragrunt output security_admin_configuration_ids
terragrunt output routing_configuration_ids
```

**Step 2**: Update `deployments.configuration_ids` in `terragrunt.hcl` with the IDs from step 1, then apply again:

```bash
terragrunt apply
```

## Dependencies

This configuration depends on:
- `../networking/vnet`: Hub VNet for hub-and-spoke topology
- `../firewall`: Azure Firewall for routing rules

## Outputs

After deployment, you can view outputs:

```bash
# Network Manager information
terragrunt output network_manager_id
terragrunt output network_manager_name

# Network Groups
terragrunt output network_group_ids

# Configuration IDs
terragrunt output connectivity_configuration_ids
terragrunt output security_admin_configuration_ids
terragrunt output routing_configuration_ids

# Deployment status
terragrunt output deployment_ids
```

## Cleanup

To destroy all resources:

```bash
terragrunt destroy
```

## Notes

1. **Two-Step Deployment**: Configurations must be created first, then deployed. The `deployments` block requires configuration IDs from the first apply.

2. **Dependencies**: Make sure dependent resources (VNet, Firewall) are deployed first.

3. **Management Group Scope**: For production environments, consider using Management Group scope instead of subscription scope.

4. **Dynamic Membership**: This example uses static membership. For dynamic membership via Azure Policy, configure separately.

## Related Documentation

- [Module README](../../../../modules/virtual-network-manager/README.md)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Azure Virtual Network Manager](https://learn.microsoft.com/en-us/azure/virtual-network-manager/)

