# ================================================================================
# TERRAFORM CONFIGURATION WITH WORKSPACES (AZURE)
# ================================================================================
# Useful for quick, isolated test on same configuration
# This configuration demonstrates Terraform Workspaces for managing multiple
# environments (dev, staging, prod) from a single codebase. Each workspace
# maintains its own state file and can have different resource configurations.

terraform {
  # Specify the minimum and maximum Terraform versions allowed
  required_version = ">= 1.0.0, < 2.0.0"

  # Define required providers and their versions
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # ================================================================================
  # AZURE BLOB STORAGE BACKEND CONFIGURATION
  # ================================================================================
  # Azure Storage Account provides both state storage AND locking (no DynamoDB needed!)
  #
  # Key differences from AWS:
  # - No DynamoDB table needed (Azure Leases handle locking natively)
  # - Simpler setup: 1 resource (Storage Account) vs 2 (S3 + DynamoDB)
  # - When using workspaces, state files are at:
  #   env:/default/terraform.tfstate
  #   env:/dev/terraform.tfstate
  #   env:/staging/terraform.tfstate
  #
  # NOTE: This backend configuration is filled in automatically at test time
  # by testing frameworks. If you wish to run this example manually, uncomment
  # and fill in the config below with your actual values.

  # backend "azurerm" {
  #   resource_group_name  = "my-rg"
  #   storage_account_name = "mytfstate"
  #   container_name       = "tfstate"
  #   key                  = "workspaces-example/terraform.tfstate"
  # }
}

# ================================================================================
# AZURE PROVIDER CONFIGURATION
# ================================================================================
# Configure the Azure provider to use the specified subscription
provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
}

# ================================================================================
# RESOURCE GROUP (REQUIRED IN AZURE)
# ================================================================================
# Azure requires all resources to belong to a resource group
# This resource group will contain the VM and its dependencies

resource "azurerm_resource_group" "example" {
  name     = "rg-${terraform.workspace}-vm"
  location = var.location

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = "Workspace Example"
  }
}

# ================================================================================
# VIRTUAL NETWORK AND SUBNET
# ================================================================================
# Required for the VM to have network connectivity

resource "azurerm_virtual_network" "example" {
  name                = "vnet-${terraform.workspace}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ================================================================================
# NETWORK INTERFACE (REQUIRED FOR AZURE VM)
# ================================================================================
# Azure VMs require a network interface attached to a subnet

resource "azurerm_network_interface" "example" {
  name                = "nic-${terraform.workspace}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# ================================================================================
# VIRTUAL MACHINE WITH WORKSPACE-AWARE CONFIGURATION
# ================================================================================
# This VM size varies based on the active workspace:
# - "default" workspace: Standard_B2s (larger, suitable for production)
# - All other workspaces: Standard_B1s (smaller, cost-effective for dev/testing)
#
# This demonstrates how to create environment-specific infrastructure from
# a single configuration file using conditional logic with terraform.workspace
#
# Note: Azure VM naming has strict rules:
# - 1-64 characters
# - Alphanumeric, hyphens only
# - Cannot end with hyphen

resource "azurerm_linux_virtual_machine" "example" {
  name                = "vm${replace(terraform.workspace, "-", "")}${substr(random_id.server.hex, 0, 4)}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # VM size depends on workspace
  # Syntax: condition ? value_if_true : value_if_false
  # - terraform.workspace: Built-in variable with current workspace name
  # - "default": The default workspace (always exists, created automatically)
  # - Standard_B2s: Larger VM (2 vCPU, 4GB RAM) for production
  # - Standard_B1s: Smaller VM (1 vCPU, 1GB RAM) for development
  size = terraform.workspace == "default" ? "Standard_B2s" : "Standard_B1s"

  # Generate unique suffix for VM name
  depends_on = [azurerm_network_interface.example]

  # Disable password authentication and use SSH keys instead
  disable_password_authentication = true

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.example.public_key_openssh
  }

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Ubuntu 20.04 LTS image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = terraform.workspace
    VMSize      = terraform.workspace == "default" ? "Standard_B2s" : "Standard_B1s"
    ManagedBy   = "Terraform"
  }
}

# ================================================================================
# SSH KEY GENERATION (FOR TESTING)
# ================================================================================
# For demonstration purposes, generate a new SSH key pair
# In production, you would use your own managed SSH keys

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_id" "server" {
  byte_length = 4
}

# ================================================================================
# PUBLIC IP (OPTIONAL - FOR ACCESSING THE VM)
# ================================================================================
# Uncomment this section if you want to access the VM from the internet

# resource "azurerm_public_ip" "example" {
#   name                = "pip-${terraform.workspace}"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   allocation_method   = "Static"
# }

# Then add to network interface:
# public_ip_address_id = azurerm_public_ip.example.id
