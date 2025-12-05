# ============================================================================
# TERRAGRUNT CONFIGURATION: Virtual Network (Production Environment)
# ============================================================================
# Production configuration with enhanced security and monitoring.
# ============================================================================

terraform {
  source = "../../../../modules//networking"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  resource_group_name = "rg-networking-prod"
  location           = "eastus"
  vnet_name          = "vnet-prod"
  address_space      = ["10.0.0.0/16"]

  # Production subnets with proper segmentation
  subnets = {
    "web-subnet" = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    "app-subnet" = {
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    "db-subnet" = {
      address_prefixes = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.Sql"]
    }
    "gateway-subnet" = {
      address_prefixes = ["10.0.4.0/24"]
    }
    "bastion-subnet" = {
      address_prefixes = ["10.0.5.0/24"]
    }
    "firewall-subnet" = {
      address_prefixes = ["10.0.6.0/24"]
    }
  }

  # Production NSG rules (more restrictive)
  network_security_groups = {
    "nsg-web" = {
      rules = [
        {
          name                       = "AllowHTTP"
          priority                   = 1000
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix       = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowHTTPS"
          priority                   = 1100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix       = "*"
          destination_address_prefix = "*"
        }
      ]
      associate_to_subnets = ["web-subnet"]
    }
  }

  # Enable DDoS Protection for production
  enable_ddos_protection = true
  
  tags = {
    Environment = "production"
    Component   = "networking"
    ManagedBy   = "Terragrunt"
  }
}
