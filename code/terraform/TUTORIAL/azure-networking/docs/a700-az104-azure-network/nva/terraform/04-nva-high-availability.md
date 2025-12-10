# Implementing High Availability for Network Virtual Appliances

## Overview

High availability is critical for NVAs since they control traffic flow. Multiple deployment methods ensure redundancy.

## Terraform Implementation

### Active-Standby Configuration

```hcl
# NVA 1 (Active)
resource "azurerm_network_interface" "nva1" {
  name                = "nic-nva1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true
  # ... IP configuration ...
}

resource "azurerm_virtual_machine" "nva1" {
  name                  = "vm-nva1"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.nva1.id]
  availability_set_id   = azurerm_availability_set.nva.id
  # ... other configuration ...
}

# NVA 2 (Standby)
resource "azurerm_network_interface" "nva2" {
  name                = "nic-nva2"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true
  # ... IP configuration ...
}

resource "azurerm_virtual_machine" "nva2" {
  name                  = "vm-nva2"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.nva2.id]
  availability_set_id   = azurerm_availability_set.nva.id
  # ... other configuration ...
}

# Availability Set
resource "azurerm_availability_set" "nva" {
  name                = "as-nva"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
}
```

### Availability Zone Deployment

```hcl
resource "azurerm_virtual_machine" "nva_zone1" {
  name                = "vm-nva-zone1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  zones               = ["1"]
  # ... other configuration ...
}

resource "azurerm_virtual_machine" "nva_zone2" {
  name                = "vm-nva-zone2"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  zones               = ["2"]
  # ... other configuration ...
}
```

## Additional Resources

- [High Availability NVAs](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/dmz/nva-ha)


