# Azure Resource Group Module

This Terraform module creates an Azure Resource Group with standardized naming conventions and tagging.

## Features

- **Standardized Naming**: Automatic name generation based on project, application, and environment
- **Flexible Configuration**: Support for optional application name
- **Tagging**: Custom tags support
- **Location**: Configurable Azure region

## Naming Convention

The resource group name follows this pattern:
- **With application_name**: `{project_name}-{application_name}-{environment}`
- **Without application_name**: `{project_name}-rg-{environment}`

### Examples

- `myproject-vnm-prod` (with application_name = "vnm")
- `myproject-rg-prod` (without application_name)
- `enterprise-network-dev` (with application_name = "network")

## Usage

### Basic Example

```hcl
module "resource_group" {
  source = "./modules/resource-group"

  project_name = "myproject"
  application_name = "vnm"
  environment     = "prod"
  location        = "eastus"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "Network Management"
  }
}
```

### Without Application Name

```hcl
module "resource_group" {
  source = "./modules/resource-group"

  project_name = "myproject"
  environment  = "dev"
  location     = "Spain Central"

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
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
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | The name of the project | `string` | n/a | yes |
| application_name | The name of the application | `string` | `""` | no |
| environment | The environment for the resource group | `string` | `"dev"` | no |
| location | The location of the resource group | `string` | `"Spain Central"` | no |
| tags | A map of tags to assign to the resource group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_id | The ID of the Resource Group |
| resource_group_name | The name of the Resource Group |
| resource_group_location | The location of the Resource Group |

## Examples

### Using in Other Modules

```hcl
module "resource_group" {
  source = "./modules/resource-group"

  project_name     = "enterprise"
  application_name = "network"
  environment      = "prod"
  location         = "eastus"
}

module "network_manager" {
  source = "./modules/virtual-network-manager"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  # ... other configuration
}
```

## Best Practices

1. **Consistent Naming**: Use the same project_name across related resources
2. **Environment Separation**: Always specify the environment (dev, staging, prod)
3. **Tagging**: Add meaningful tags for cost tracking and resource management
4. **Location**: Use consistent locations across environments when possible

## References

- [Azure Resource Groups Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Terraform Azure Provider - Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)

