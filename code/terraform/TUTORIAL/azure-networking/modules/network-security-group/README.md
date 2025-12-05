# Azure Network Security Group Module

This module creates an Azure Network Security Group (NSG) with configurable security rules.

## Features

- Network Security Group creation
- Inbound and outbound security rules
- Service tag support
- Application Security Group support
- Subnet associations
- Port range support
- Multiple source/destination prefixes

## Usage

### Basic NSG with HTTP/HTTPS Rules

```hcl
module "web_nsg" {
  source = "./modules/network-security-group"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  nsg_name            = "nsg-web"
  
  security_rules = [
    {
      name                       = "AllowHTTP"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range    = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP traffic"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 1100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range    = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTPS traffic"
    }
  ]
  
  associate_to_subnets = [
    azurerm_subnet.web.id
  ]
  
  tags = {
    Environment = "Production"
  }
}
```

### NSG with Service Tags

```hcl
module "app_nsg" {
  source = "./modules/network-security-group"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  nsg_name            = "nsg-app"
  
  security_rules = [
    {
      name                       = "AllowVNetInbound"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow all traffic from VNet"
    },
    {
      name                       = "AllowAzureLoadBalancer"
      priority                   = 1100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow traffic from Azure Load Balancer"
    },
    {
      name                       = "AllowStorage"
      priority                   = 1200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "Storage"
      description                = "Allow outbound to Azure Storage"
    }
  ]
  
  associate_to_subnets = [
    azurerm_subnet.app.id
  ]
}
```

### NSG with Port Ranges

```hcl
module "db_nsg" {
  source = "./modules/network-security-group"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  nsg_name            = "nsg-db"
  
  security_rules = [
    {
      name                       = "AllowSQLFromApp"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges   = ["1433", "11000-11999"]  # SQL Server ports
      source_address_prefix      = "10.0.2.0/24"  # App subnet
      destination_address_prefix = "*"
      description                = "Allow SQL Server from app subnet"
    },
    {
      name                       = "DenyInternet"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny all internet traffic"
    }
  ]
  
  associate_to_subnets = [
    azurerm_subnet.db.id
  ]
}
```

### NSG with Multiple Source Prefixes

```hcl
module "secure_nsg" {
  source = "./modules/network-security-group"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  nsg_name            = "nsg-secure"
  
  security_rules = [
    {
      name                        = "AllowSSHFromSpecificIPs"
      priority                    = 1000
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "22"
      source_address_prefixes     = ["203.0.113.0/24", "198.51.100.0/24"]  # Specific IP ranges
      destination_address_prefix  = "*"
      description                 = "Allow SSH from specific IP ranges"
    }
  ]
  
  associate_to_subnets = [
    azurerm_subnet.secure.id
  ]
}
```

## Important Notes

### Rule Priority

- **Priority range**: 100-4096 (lower number = higher priority)
- **Evaluation order**: Rules are evaluated in priority order (lowest first)
- **First match wins**: First matching rule is applied
- **Default rules**: Cannot be deleted, but can be overridden

### Default Rules

Every NSG has default rules that cannot be deleted:

**Inbound:**
- `AllowVNetInBound` (Priority 65000): Allow all inbound from VNet
- `AllowAzureLoadBalancerInBound` (Priority 65001): Allow inbound from Azure Load Balancer
- `DenyAllInBound` (Priority 65500): Deny all other inbound

**Outbound:**
- `AllowVNetOutBound` (Priority 65000): Allow all outbound to VNet
- `AllowInternetOutBound` (Priority 65001): Allow all outbound to Internet
- `DenyAllOutBound` (Priority 65500): Deny all other outbound

### Service Tags

Common service tags:
- `VirtualNetwork`: All IP addresses in the VNet
- `Internet`: All public IP addresses
- `AzureLoadBalancer`: Azure Load Balancer
- `Storage`: Azure Storage service
- `Sql`: Azure SQL Database
- `AzureKeyVault`: Azure Key Vault
- `AzureMonitor`: Azure Monitor

### Port Configuration

- **Single port**: Use `source_port_range` or `destination_port_range`
- **Port ranges**: Use `source_port_ranges` or `destination_port_ranges`
- **All ports**: Use `"*"`

### Association Priority

- **Subnet association**: All VMs in subnet inherit rules
- **NIC association**: Rules apply to specific network interface
- **Both**: If NSG is associated to both subnet and NIC, both rule sets apply
- **Evaluation**: Subnet NSG → NIC NSG (most restrictive wins)

## Requirements

- Resource group must exist
- Subnet IDs must be valid (if associating to subnets)
- Rule priorities must be unique within the NSG
- Port ranges must be valid (1-65535)

## Outputs

- `nsg_id`: The ID of the Network Security Group
- `nsg_name`: The name of the Network Security Group
- `security_rule_ids`: Map of security rule names to their IDs
- `associated_subnet_ids`: List of subnet IDs associated with this NSG

## Additional Resources

- [Network Security Groups Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Security Rules](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-group-how-it-works)
- [Service Tags](https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview)


