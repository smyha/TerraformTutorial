terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  sensitive   = true
}

provider "azurerm" {
  features {}
}

provider "tls" {}

# Generate an SSH private key for secure VM access
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Define an Azure Resource Group
# Resource groups are containers that hold related resources for an Azure solution
resource "azurerm_resource_group" "example" {
  name     = "rg-terraform-example"
  location = "East US"

  tags = {
    Name = "terraform-example"
  }
}

# Define an Azure Virtual Network
# Virtual networks provide isolated network environments for your resources
resource "azurerm_virtual_network" "example" {
  name                = "vnet-terraform-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define a subnet within the virtual network
# Subnets allow you to segment the virtual network into smaller networks
resource "azurerm_subnet" "internal" {
  name                 = "subnet-terraform-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Define a public IP address
# This IP address will be assigned to the VM for external access
resource "azurerm_public_ip" "example" {
  name                = "pip-terraform-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Define a network interface
# Network interfaces attach VMs to subnets and manage IP configurations
resource "azurerm_network_interface" "example" {
  name                = "nic-terraform-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Define a Linux Virtual Machine
# This is the core compute resource that will run your workloads
resource "azurerm_linux_virtual_machine" "example" {
  name                = "vm-terraform-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_B1s"

  admin_username = "azureuser"

  # Configure SSH key authentication for secure access
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example.public_key_openssh
  }

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Name = "terraform-example"
  }
}
