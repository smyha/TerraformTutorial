# Azure Networking Tutorial - Quick Start Guide

This quick start guide will help you get started with the Azure Networking tutorial.

## Prerequisites

1. **Azure Account**: An active Azure subscription
2. **Azure CLI**: Installed and configured
3. **Terraform**: Version >= 1.0
4. **Permissions**: Contributor or Owner role on the subscription

## Step 1: Authenticate with Azure

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "Your Subscription ID"

# Verify your subscription
az account show
```

## Step 2: Choose an Example

### Option A: Basic Virtual Network

The simplest example - creates a VNet with subnets and NSGs.

```bash
cd examples/basic-vnet
terraform init
terraform plan
terraform apply
```

**What it creates:**
- Resource Group
- Virtual Network (10.0.0.0/16)
- 3 Subnets (Web, App, DB)
- 3 Network Security Groups with rules

### Option B: Multi-Tier Application

Complete multi-tier application with load balancing.

```bash
cd examples/multi-tier-app
terraform init
terraform plan
terraform apply
```

**What it creates:**
- Virtual Network with multiple subnets
- Load Balancer for web tier
- Application Gateway for app tier
- Network Security Groups
- Route tables

## Step 3: Understand the Modules

### Core Networking Module

```hcl
module "vnet" {
  source = "./modules/networking"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vnet_name           = "prod-vnet"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "web-subnet" = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}
```

### Load Balancer Module

```hcl
module "load_balancer" {
  source = "./modules/load-balancer"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  load_balancer_name  = "web-lb"
  sku                 = "Standard"
  
  frontend_ip_configurations = [
    {
      name                 = "public-frontend"
      public_ip_address_id = azurerm_public_ip.lb.id
    }
  ]
}
```

### Firewall Module

```hcl
module "firewall" {
  source = "./modules/firewall"
  
  resource_group_name    = "rg-example"
  location              = "eastus"
  firewall_name         = "hub-firewall"
  firewall_subnet_id    = azurerm_subnet.firewall.id
  public_ip_address_id  = azurerm_public_ip.firewall.id
  
  network_rule_collections = [
    {
      name     = "AllowInternet"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name                  = "AllowHTTPS"
          source_addresses      = ["*"]
          destination_addresses = ["*"]
          destination_ports     = ["443"]
          protocols             = ["TCP"]
        }
      ]
    }
  ]
}
```

## Step 4: Review Documentation

### Main Documentation

- **Complete Guide**: `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
  - Comprehensive overview of all services
  - Architecture diagrams
  - Use cases and best practices

- **Service Comparisons**: `docs/SERVICE_COMPARISONS.md`
  - Detailed comparisons between similar services
  - Decision trees
  - Cost and performance comparisons

### Module Documentation

Each module includes:
- `README.md`: Usage examples
- `variables.tf`: Input documentation
- `outputs.tf`: Output documentation
- `main.tf`: Detailed code comments

## Step 5: Customize for Your Needs

### Modify Address Spaces

```hcl
# Change VNet address space
address_space = ["172.16.0.0/16"]

# Change subnet address prefixes
subnets = {
  "web-subnet" = {
    address_prefixes = ["172.16.1.0/24"]
  }
}
```

### Add More Subnets

```hcl
subnets = {
  "web-subnet" = {
    address_prefixes = ["10.0.1.0/24"]
  }
  "app-subnet" = {
    address_prefixes = ["10.0.2.0/24"]
  }
  "db-subnet" = {
    address_prefixes = ["10.0.3.0/24"]
  }
  "dmz-subnet" = {
    address_prefixes = ["10.0.4.0/24"]
  }
}
```

### Add NSG Rules

```hcl
network_security_groups = {
  "web-nsg" = {
    rules = [
      {
        name                       = "AllowHTTP"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      # Add more rules here
    ]
    associate_to_subnets = ["web-subnet"]
  }
}
```

## Step 6: Clean Up

When you're done experimenting:

```bash
# Destroy all resources
terraform destroy

# Or destroy specific resources
terraform destroy -target=module.vnet
```

## Common Tasks

### View Resources

```bash
# List resource groups
az group list

# List virtual networks
az network vnet list

# List load balancers
az network lb list
```

### Troubleshooting

1. **Authentication Issues**
   ```bash
   az login --tenant "Your Tenant ID"
   az account set --subscription "Your Subscription ID"
   ```

2. **Provider Version Issues**
   ```bash
   terraform init -upgrade
   ```

3. **State Issues**
   ```bash
   terraform refresh
   terraform state list
   ```

## Next Steps

1. **Explore Modules**: Review each module's code and comments
2. **Read Documentation**: Study the complete guide and comparisons
3. **Try Examples**: Run different examples to understand patterns
4. **Build Your Own**: Create your own configurations using the modules
5. **Best Practices**: Review best practices in the documentation

## Resources

- [Azure Networking Documentation](https://docs.microsoft.com/azure/networking/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)

## Support

For issues or questions:
1. Check the module documentation
2. Review the complete guide
3. Check Azure documentation
4. Review Terraform provider documentation

---

**Happy Networking!** 🚀

