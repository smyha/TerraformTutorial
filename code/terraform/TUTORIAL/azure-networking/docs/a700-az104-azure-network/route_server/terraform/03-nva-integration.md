# NVA Integration with Route Server

## Overview

This guide explains how to integrate Network Virtual Appliances (NVAs) with Azure Route Server. NVAs must be properly configured with BGP and IP forwarding to exchange routes with Route Server.

## NVA Requirements

### Essential Requirements

1. **BGP Support**: NVA must support BGP protocol
2. **IP Forwarding**: Must be enabled on NVA's network interface
3. **Unique ASN**: Must use ASN different from Route Server's ASN (65515)
4. **Network Access**: Must be in same VNet or peered VNet
5. **Static IP**: Should use static IP address for BGP peering

## NVA Deployment

### Basic NVA with IP Forwarding

```hcl
# Subnet for NVA
resource "azurerm_subnet" "nva" {
  name                 = "NVASubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Interface with IP Forwarding
resource "azurerm_network_interface" "nva" {
  name                = "nic-nva"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  enable_ip_forwarding = true  # Required for NVA

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"  # Static IP for BGP
  }
}

# Network Security Group for NVA
resource "azurerm_network_security_group" "nva" {
  name                = "nsg-nva"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow BGP (TCP 179)
  security_rule {
    name                       = "AllowBGP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "179"
    source_address_prefix      = "10.0.1.0/27"  # Route Server subnet
    destination_address_prefix = "*"
  }

  # Allow traffic from VNet
  security_rule {
    name                       = "AllowVNet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nva" {
  network_interface_id      = azurerm_network_interface.nva.id
  network_security_group_id = azurerm_network_security_group.nva.id
}

# Virtual Machine (NVA)
resource "azurerm_linux_virtual_machine" "nva" {
  name                = "vm-nva"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"

  network_interface_ids = [azurerm_network_interface.nva.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

## Route Server Integration

### Creating Route Server

```hcl
# Route Server Subnet
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/27"]
}

# Public IP for Route Server
resource "azurerm_public_ip" "route_server" {
  name                = "pip-routeserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Route Server
resource "azurerm_route_server" "main" {
  name                = "rs-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  subnet_id           = azurerm_subnet.route_server.id
  public_ip_address_id = azurerm_public_ip.route_server.id
}
```

### BGP Peer Connection

```hcl
# BGP Peer Connection
resource "azurerm_route_server_bgp_connection" "nva" {
  name            = "bgp-nva"
  route_server_id = azurerm_route_server.main.id
  peer_asn        = 65001  # NVA's ASN
  peer_ip         = "10.0.2.10"  # NVA's IP address
}
```

## NVA BGP Configuration

### Example: VyOS Router Configuration

```hcl
# VyOS Router NVA
resource "azurerm_linux_virtual_machine" "vyos" {
  name                = "vm-vyos-router"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_D2s_v3"
  admin_username      = "vyos"

  network_interface_ids = [azurerm_network_interface.vyos.id]

  # Use VyOS image from marketplace
  source_image_reference {
    publisher = "vyos"
    offer     = "vyos"
    sku       = "next"
    version   = "latest"
  }
}
```

**VyOS BGP Configuration (manual):**
```
configure
set protocols bgp 65001 neighbor 10.0.1.4 remote-as 65515
set protocols bgp 65001 neighbor 10.0.1.5 remote-as 65515
set protocols bgp 65001 network 10.1.0.0/16
commit
save
```

### Example: Palo Alto Firewall

Palo Alto firewalls support BGP and can peer with Route Server.

**Palo Alto BGP Configuration:**
- Enable BGP in Network > Virtual Routers
- Configure BGP peer with Route Server IPs
- Set local ASN (e.g., 65001)
- Advertise routes

## High Availability NVA Deployment

### Active-Active Configuration

Deploy multiple NVAs with the same ASN for load balancing.

```hcl
# NVA 1
resource "azurerm_network_interface" "nva1" {
  name                = "nic-nva-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

# NVA 2
resource "azurerm_network_interface" "nva2" {
  name                = "nic-nva-2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.11"
  }
}

# BGP Peer 1
resource "azurerm_route_server_bgp_connection" "nva1" {
  name            = "bgp-nva-1"
  route_server_id = azurerm_route_server.main.id
  peer_asn        = 65001
  peer_ip         = "10.0.2.10"
}

# BGP Peer 2 (same ASN for active-active)
resource "azurerm_route_server_bgp_connection" "nva2" {
  name            = "bgp-nva-2"
  route_server_id = azurerm_route_server.main.id
  peer_asn        = 65001  # Same ASN
  peer_ip         = "10.0.2.11"
}
```

## Complete Example

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Route Server Subnet
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/27"]
}

# NVA Subnet
resource "azurerm_subnet" "nva" {
  name                 = "NVASubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP for Route Server
resource "azurerm_public_ip" "route_server" {
  name                = "pip-routeserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Route Server
resource "azurerm_route_server" "main" {
  name                = "rs-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  subnet_id           = azurerm_subnet.route_server.id
  public_ip_address_id = azurerm_public_ip.route_server.id
}

# NVA Network Interface
resource "azurerm_network_interface" "nva" {
  name                = "nic-nva"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

# BGP Peer Connection
resource "azurerm_route_server_bgp_connection" "nva" {
  name            = "bgp-nva"
  route_server_id = azurerm_route_server.main.id
  peer_asn        = 65001
  peer_ip         = "10.0.2.10"
}

# Output Route Server IPs for NVA Configuration
output "route_server_ips" {
  description = "Route Server IP addresses for BGP peering"
  value       = azurerm_route_server.main.virtual_router_ips
}

output "route_server_asn" {
  description = "Route Server ASN (for NVA BGP configuration)"
  value       = azurerm_route_server.main.virtual_router_asn
}
```

## NVA BGP Configuration Steps

After deploying the infrastructure, configure BGP on the NVA:

1. **Get Route Server Information:**
   - ASN: Always 65515
   - IP Addresses: From `route_server_ips` output (typically 2 IPs)

2. **Configure BGP on NVA:**
   - Set local ASN (e.g., 65001)
   - Add Route Server as BGP neighbor
   - Configure both Route Server IPs as neighbors
   - Advertise routes to Route Server

3. **Verify BGP Session:**
   - Check BGP session is established
   - Verify routes are being exchanged
   - Monitor route propagation

## Best Practices

1. **IP Forwarding**: Always enable IP forwarding on NVA interfaces
2. **Static IPs**: Use static IP addresses for NVAs
3. **NSG Rules**: Allow BGP (TCP 179) from Route Server subnet
4. **High Availability**: Deploy multiple NVAs for redundancy
5. **Monitoring**: Monitor BGP sessions and route counts
6. **Documentation**: Document ASN assignments and IP addresses

## Troubleshooting

### BGP Session Not Established

**Check:**
- IP forwarding is enabled on NVA
- NSG allows BGP (TCP 179) from Route Server subnet
- NVA can reach Route Server subnet
- BGP is properly configured on NVA
- ASN is different from 65515

### Routes Not Propagating

**Check:**
- BGP session is established
- NVA is advertising routes
- Route prefixes are valid
- Route Server is in same VNet

## Additional Resources

- [NVA Deployment Guide](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/dmz/nva-ha)
- [BGP Configuration](https://learn.microsoft.com/en-us/azure/route-server/quickstart-configure-route-server)
- [IP Forwarding](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface#enable-or-disable-ip-forwarding)

