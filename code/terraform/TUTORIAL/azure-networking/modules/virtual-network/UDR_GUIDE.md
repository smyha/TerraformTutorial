# User-Defined Routes (UDR) Guide

## Overview

User-Defined Routes (UDR) allow you to override Azure's default routing behavior by creating custom routes that control how traffic flows in your Virtual Network. This guide explains UDR concepts, next hop types, and effective routes.

## What are User-Defined Routes?

User-Defined Routes are custom routes that you create to control traffic routing in your Azure Virtual Network. They override Azure's default system routes for specific address prefixes.

**Key Concepts:**
- Routes are defined in Route Tables
- Route Tables are associated with Subnets
- Routes specify destination (address prefix) and next hop
- Routes are evaluated in order of specificity (most specific first)

## Route Tables

Route Tables are containers for user-defined routes. They can be associated with one or more subnets.

**Characteristics:**
- Each subnet can have only one route table
- Route tables can be shared across multiple subnets
- Routes in a route table apply to all associated subnets
- BGP route propagation can be disabled per route table

## Next Hop Types

Next hop types define where traffic is sent when a route matches. Azure supports the following next hop types:

### 1. VirtualAppliance

Routes traffic through a Network Virtual Appliance (NVA), such as a firewall or router.

**Use Cases:**
- Forced tunneling (route all internet traffic through NVA)
- Traffic inspection and filtering
- Network security enforcement
- WAN optimization

**Requirements:**
- Must specify `next_hop_in_ip_address` (NVA's IP address)
- NVA must have IP forwarding enabled
- NVA must be in the same VNet or peered VNet

**Example:**
```hcl
route = {
  name                   = "route-nva-default"
  address_prefix         = "0.0.0.0/0"  # All traffic
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.1.10"   # NVA IP
}
```

### 2. VirtualNetworkGateway

Routes traffic through a VPN Gateway or ExpressRoute Gateway.

**Use Cases:**
- On-premises connectivity
- Site-to-site VPN
- ExpressRoute connections
- Hybrid cloud scenarios

**Requirements:**
- VPN Gateway or ExpressRoute Gateway must exist
- Gateway must be in the same VNet
- Used for routing to on-premises networks

**Example:**
```hcl
route = {
  name             = "route-onprem"
  address_prefix   = "10.1.0.0/16"  # On-premises network
  next_hop_type    = "VirtualNetworkGateway"
}
```

### 3. VnetLocal

Routes traffic within the Virtual Network (default behavior for VNet subnets).

**Use Cases:**
- Explicit routing within VNet
- Override other routes for VNet traffic
- Ensure local VNet traffic stays local

**Example:**
```hcl
route = {
  name          = "route-vnet-local"
  address_prefix = "10.0.0.0/16"  # VNet address space
  next_hop_type = "VnetLocal"
}
```

### 4. Internet

Routes traffic directly to the Internet.

**Use Cases:**
- Direct internet access
- Override forced tunneling for specific destinations
- Allow internet access for specific subnets

**Example:**
```hcl
route = {
  name          = "route-internet"
  address_prefix = "0.0.0.0/0"  # All traffic
  next_hop_type  = "Internet"
}
```

### 5. None (Blackhole)

Drops traffic to specific destinations.

**Use Cases:**
- Block access to specific networks
- Security policies
- Prevent traffic to unwanted destinations

**Example:**
```hcl
route = {
  name          = "route-block"
  address_prefix = "192.168.0.0/16"  # Block this network
  next_hop_type  = "None"
}
```

### 6. VnetPeering

Routes traffic to a peered Virtual Network.

**Use Cases:**
- Cross-VNet routing
- Hub-spoke topologies
- Multi-VNet architectures

**Requirements:**
- VNet peering must be established
- Used for routing between peered VNets

**Example:**
```hcl
route = {
  name          = "route-peered-vnet"
  address_prefix = "10.2.0.0/16"  # Peered VNet address space
  next_hop_type  = "VnetPeering"
}
```

## Route Evaluation and Effective Routes

### How Routes Are Evaluated

Routes are evaluated in the following order:

1. **User-Defined Routes**: Custom routes in route tables
2. **BGP Routes**: Routes learned via BGP (if propagation enabled)
3. **System Routes**: Default Azure routes

**Priority Rules:**
- Most specific route (smallest prefix) is matched first
- User-defined routes override system routes for matching prefixes
- If multiple routes match, the most specific route wins
- Longest prefix match determines which route is used

### Effective Routes

Effective routes are the actual routes that are active for a network interface. They combine:
- System routes (default Azure routes)
- User-defined routes (from route tables)
- BGP routes (if BGP propagation is enabled)

**Viewing Effective Routes:**

You can view effective routes for a network interface using:

**Azure Portal:**
1. Navigate to Network Interface
2. Go to "Effective routes" under "Support + troubleshooting"

**Azure CLI:**
```bash
az network nic show-effective-route-table \
  --resource-group <rg-name> \
  --name <nic-name>
```

**PowerShell:**
```powershell
Get-AzEffectiveRouteTable -NetworkInterfaceName <nic-name> -ResourceGroupName <rg-name>
```

### System Routes

Azure automatically creates system routes for:
- **VNet local**: Routes within the VNet (10.0.0.0/16 → VnetLocal)
- **Internet**: Routes to internet (0.0.0.0/0 → Internet)
- **Virtual Network Gateway**: Routes to on-premises (if gateway exists)
- **VNet Peering**: Routes to peered VNets (if peering exists)
- **Service Endpoints**: Routes to Azure services (if enabled)

### Route Priority Example

Consider the following routes:

```
Route 1: 10.0.0.0/16 → VnetLocal
Route 2: 10.0.1.0/24 → VirtualAppliance (10.0.1.10)
Route 3: 0.0.0.0/0 → Internet
```

**Traffic to 10.0.1.5:**
- Matches Route 2 (most specific: /24)
- Traffic goes to NVA at 10.0.1.10

**Traffic to 10.0.2.5:**
- Matches Route 1 (VNet local: /16)
- Traffic stays within VNet

**Traffic to 8.8.8.8:**
- Matches Route 3 (default: /0)
- Traffic goes to Internet

## Common UDR Scenarios

### Scenario 1: Forced Tunneling

Route all internet traffic through an NVA for inspection.

```hcl
route_tables = {
  "rt-forced-tunnel" = {
    disable_bgp_route_propagation = false
  }
}

routes = {
  "route-internet-via-nva" = {
    name                   = "route-internet-via-nva"
    route_table_name       = "rt-forced-tunnel"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.10"  # Firewall NVA
  }
}

subnets = {
  "subnet-web" = {
    address_prefixes = ["10.0.1.0/24"]
    route_table_name = "rt-forced-tunnel"
  }
}
```

### Scenario 2: Route Specific Traffic Through NVA

Route only specific networks through an NVA, allow direct internet for others.

```hcl
routes = {
  "route-internal-via-nva" = {
    name                   = "route-internal-via-nva"
    route_table_name       = "rt-nva"
    address_prefix         = "10.1.0.0/16"  # Internal network
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.10"
  }
  # Internet traffic uses default system route (direct to internet)
}
```

### Scenario 3: Block Specific Networks

Block access to specific networks using blackhole routes.

```hcl
routes = {
  "route-block" = {
    name             = "route-block-unwanted"
    route_table_name = "rt-security"
    address_prefix   = "192.168.0.0/16"
    next_hop_type    = "None"  # Blackhole
  }
}
```

### Scenario 4: On-Premises Connectivity

Route on-premises traffic through VPN Gateway.

```hcl
routes = {
  "route-onprem" = {
    name             = "route-onprem"
    route_table_name = "rt-hybrid"
    address_prefix   = "10.1.0.0/16"  # On-premises network
    next_hop_type    = "VirtualNetworkGateway"
  }
}
```

## Best Practices

1. **Route Specificity**: Use the most specific route possible
2. **Route Tables**: Organize routes logically in route tables
3. **Documentation**: Document route purposes and next hops
4. **Testing**: Test routes in non-production first
5. **Monitoring**: Monitor effective routes and traffic flow
6. **NVA High Availability**: Deploy multiple NVAs for redundancy
7. **Route Validation**: Validate routes don't create routing loops

## Troubleshooting

### Routes Not Working

**Check:**
- Route table is associated with subnet
- Route prefix matches destination
- Next hop is reachable
- NVA has IP forwarding enabled (for VirtualAppliance)
- Gateway is operational (for VirtualNetworkGateway)

### Traffic Not Reaching NVA

**Check:**
- NVA IP address is correct
- NVA has IP forwarding enabled
- NSG rules allow traffic
- Route table is associated with source subnet

### Effective Routes Not Showing Custom Routes

**Check:**
- Route table is associated with subnet
- Routes are defined in route table
- Route prefixes are valid
- BGP propagation is enabled if using BGP routes

## Additional Resources

- [Azure User-Defined Routes](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [Effective Routes](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-routes-troubleshooting)
- [Route Table Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/manage-route-table)

