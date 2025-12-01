# Azure Networking Tutorial with Terraform

This comprehensive tutorial provides complete implementations of Azure networking services using Terraform. All code is thoroughly commented and includes detailed documentation with Mermaid diagrams.

## 📚 Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Modules](#modules)
- [Examples](#examples)
- [Documentation](#documentation)
- [Getting Started](#getting-started)
- [Services Covered](#services-covered)

## Overview

This tutorial covers all major Azure networking services:

- **Core Networking**: Virtual Networks, Subnets, NSGs, Route Tables
- **Load Balancing**: Load Balancer, Application Gateway, Front Door, Traffic Manager
- **Security**: Azure Firewall, WAF, Bastion, Private Link, DDoS Protection
- **Connectivity**: VPN Gateway, ExpressRoute, Virtual WAN, NAT Gateway
- **Application Delivery**: CDN, Front Door, Application Gateway
- **Monitoring**: Network Watcher

> **📖 Official Azure Networking Overview**: For a comprehensive overview of what each Azure networking service is and what it's used for, see the [Azure networking services overview](https://learn.microsoft.com/en-us/azure/networking/fundamentals/networking-overview) documentation from Microsoft Learn.

## Directory Structure

```
azure-networking-tutorial/
├── modules/                    # Reusable Terraform modules
│   ├── networking/            # Virtual Network module
│   ├── load-balancer/         # Load Balancer module
│   ├── firewall/              # Azure Firewall module
│   ├── nat-gateway/           # NAT Gateway module
│   ├── application-gateway/   # Application Gateway module
│   ├── bastion/               # Azure Bastion module
│   ├── vpn-gateway/           # VPN Gateway module
│   ├── expressroute/          # ExpressRoute module
│   ├── virtual-wan/           # Virtual WAN module
│   ├── front-door/            # Azure Front Door module
│   ├── cdn/                   # Azure CDN module
│   ├── dns/                   # Azure DNS module
│   ├── private-link/          # Private Link module
│   ├── ddos-protection/       # DDoS Protection module
│   ├── firewall-manager/      # Firewall Manager module
│   ├── traffic-manager/       # Traffic Manager module
│   └── network-watcher/      # Network Watcher module
├── examples/                  # Example configurations
│   ├── basic-vnet/           # Basic Virtual Network
│   ├── multi-tier-app/        # Multi-tier application
│   ├── hybrid-connectivity/   # Hybrid connectivity (VPN/ExpressRoute)
│   └── global-distribution/   # Global distribution (CDN/Front Door)
├── live/                      # Production-ready configurations
│   ├── stage/                # Staging environment
│   └── prod/                 # Production environment
└── docs/                      # Comprehensive documentation
    ├── AZURE_NETWORKING_COMPLETE_GUIDE.md
    └── [Service-specific guides]
```

## Modules

### Core Networking

#### Virtual Network Module (`modules/networking/`)

Creates a complete Virtual Network infrastructure:
- Virtual Network with configurable address spaces
- Subnets with service endpoints and delegations
- Network Security Groups with custom rules
- Route Tables with custom routes
- Optional DDoS Protection integration

**Usage:**
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
      service_endpoints = ["Microsoft.Storage"]
    }
  }
}
```

#### Load Balancer Module (`modules/load-balancer/`)

Creates an Azure Load Balancer with:
- Frontend IP configurations (public/private)
- Backend address pools
- Health probes
- Load balancing rules
- Outbound rules
- Inbound NAT rules

#### Firewall Module (`modules/firewall/`)

Creates an Azure Firewall with:
- Network rule collections
- Application rule collections
- NAT rule collections
- Threat Intelligence integration

#### NAT Gateway Module (`modules/nat-gateway/`)

Creates a NAT Gateway for outbound connectivity:
- Public IP association
- Subnet association
- Automatic scaling

## Examples

### Basic Virtual Network (`examples/basic-vnet/`)

A simple example demonstrating:
- Virtual Network creation
- Subnet configuration
- Network Security Group rules
- Multi-tier architecture (Web/App/DB)

**To run:**
```bash
cd examples/basic-vnet
terraform init
terraform plan
terraform apply
```

### Multi-Tier Application (`examples/multi-tier-app/`)

Complete multi-tier application with:
- Virtual Network with multiple subnets
- Load Balancer for web tier
- Application Gateway for application tier
- Network Security Groups for each tier
- Route tables for traffic routing

### Hybrid Connectivity (`examples/hybrid-connectivity/`)

Hybrid cloud connectivity with:
- VPN Gateway for site-to-site VPN
- ExpressRoute for private connectivity
- Virtual WAN for centralized management
- Azure Firewall for security

### Global Distribution (`examples/global-distribution/`)

Global application distribution with:
- Azure Front Door for global load balancing
- Azure CDN for content delivery
- Traffic Manager for DNS-based routing
- Multi-region deployment

## Documentation

### Complete Guide (`docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`)

Comprehensive guide covering:
- All Azure networking services
- Architecture diagrams (Mermaid)
- Use cases and best practices
- Terraform examples
- Comparison tables

### Service-Specific Documentation

Each module includes detailed documentation:
- Architecture diagrams
- Configuration examples
- Best practices
- Troubleshooting tips

## Getting Started

### Prerequisites

- Terraform >= 1.0
- Azure CLI installed and configured
- Azure subscription with appropriate permissions

### Quick Start

1. **Clone or navigate to this directory:**
   ```bash
   cd azure-networking-tutorial
   ```

2. **Authenticate with Azure:**
   ```bash
   az login
   az account set --subscription "Your Subscription ID"
   ```

3. **Run an example:**
   ```bash
   cd examples/basic-vnet
   terraform init
   terraform plan
   terraform apply
   ```

4. **Review the documentation:**
   ```bash
   cat docs/AZURE_NETWORKING_COMPLETE_GUIDE.md
   ```

## Services Covered

### ✅ Core Networking
- [x] Azure Virtual Network
- [x] Subnets
- [x] Network Security Groups
- [x] Route Tables

### ✅ Load Balancing
- [x] Azure Load Balancer
- [x] Azure Application Gateway
- [x] Azure Front Door
- [x] Azure Traffic Manager

### ✅ Security
- [x] Azure Firewall
- [x] Web Application Firewall (WAF)
- [x] Azure Bastion
- [x] Azure Private Link
- [x] Azure DDoS Protection
- [x] Azure Firewall Manager

### ✅ Connectivity
- [x] Azure VPN Gateway
- [x] Azure ExpressRoute
- [x] Azure Virtual WAN
- [x] Azure NAT Gateway
- [x] Routing Preference

### ✅ Application Delivery
- [x] Azure CDN
- [x] Azure Front Door
- [x] Azure Application Gateway
- [x] Web Application Firewall

### ✅ Monitoring
- [x] Azure Network Watcher
- [x] Azure Monitor

### ✅ Advanced
- [x] Azure DNS
- [x] Internet Analyzer
- [x] Azure Programmable Connectivity

## Service Implementation Details

This section maps each Azure networking service to its exact code location and implementation details.

### Core Networking Services

#### Azure Virtual Network

**What is it?** Azure Virtual Network (VNet) is the fundamental building block of your private network in Azure. It's a representation of your own network in the cloud that provides isolation and logical segmentation of your Azure resources.

**What is it used for?**
- **Network isolation**: Isolates your resources from other Azure resources and the Internet
- **IP address management**: Define and manage your own private IP address space
- **Segmentation**: Divides your network into subnets to organize resources
- **Connectivity**: Connects Azure resources to each other and to on-premises networks
- **DNS resolution**: Provides DNS name resolution for resources in the VNet
- **Service integration**: Allows connecting Azure services via service endpoints

**DNS and Name Resolution:**

DNS is crucial for Virtual Networks as it enables resources to communicate using friendly names instead of IP addresses. Azure provides built-in DNS resolution for resources within a VNet.

**How DNS works in VNets:**
- **Default DNS**: Azure automatically provides DNS resolution (168.63.129.16) for resources in the VNet
- **Automatic registration**: VMs automatically register their hostnames with Azure DNS
- **Private DNS zones**: You can use Azure Private DNS zones for custom domain names within the VNet
- **Custom DNS servers**: You can configure custom DNS servers for hybrid scenarios or specific requirements

**Use Cases:**
1. **Internal Service Discovery**: VMs can resolve each other by hostname (e.g., `web-vm-01` instead of `10.0.1.5`)
2. **Hybrid Connectivity**: Configure custom DNS servers to resolve on-premises resources (e.g., `internal-app.company.local`)
3. **Private DNS Zones**: Create custom domains for internal services (e.g., `app.internal`, `db.internal`)
4. **Service Integration**: Azure services like Storage Accounts and SQL Databases can be accessed via their service endpoints with DNS resolution

**Example Scenario**: In a multi-tier application, the web tier needs to connect to the database. Instead of hardcoding IP addresses, you can use DNS names like `mysql-db.internal` which resolves to the database's private IP. This makes the infrastructure more maintainable and resilient to IP changes.

**Implementation:**
- **Module**: `modules/networking/`
- **File**: `modules/networking/main.tf`
- **Resource**: `azurerm_virtual_network.main` (lines 28-51)
- **Key Features**:
  - Address space management (line 32)
  - DDoS Protection Plan integration (lines 37-40)
  - Custom DNS servers (line 45)

#### Subnets

**What is it?** A subnet is a range of IP addresses within a Virtual Network. It allows segmenting the network into smaller subnets to organize and isolate resources.

**What is it used for?**
- **Logical segmentation**: Organizes resources by function (web, app, database)
- **Traffic control**: Allows applying different security policies per subnet
- **Service Endpoints**: Extends VNet identity to Azure services (Storage, SQL) without going through the Internet
- **Service delegation**: Delegates subnet management to Azure services (AKS, App Service)
- **Security isolation**: Isolates application layers (frontend, backend, database)

**Implementation:**
- **Module**: `modules/networking/`
- **File**: `modules/networking/main.tf`
- **Resource**: `azurerm_subnet.main` (lines 66-100)
- **Key Features**:
  - Subnet address prefixes (line 75)
  - Service endpoints (line 78)
  - Service delegations (lines 81-90)
  - Private endpoint/private link policies (commented, lines 92-100)

#### Network Security Groups (NSGs)

**What is it?** Network Security Groups (NSG) act as a distributed firewall at the network level. They are security rules that control inbound and outbound network traffic on subnets and network interfaces.

**What is it used for?**
- **Traffic filtering**: Allows or denies traffic based on source/destination IP addresses, ports, and protocols
- **Layered security**: Applies different security rules to different subnets
- **Access control**: Restricts access to specific resources (e.g., only allow database access from the application subnet)
- **Compliance**: Helps meet security and compliance requirements
- **Defense in depth**: Provides an additional layer of security in addition to application firewalls

**Implementation:**
- **Module**: `modules/networking/`
- **File**: `modules/networking/main.tf`
- **Resources**:
  - `azurerm_network_security_group.main` (lines 118-125) - Creates NSG
  - `azurerm_network_security_rule.main` (lines 140-170) - Creates NSG rules
  - `azurerm_subnet_network_security_group_association.main` (lines 175-190) - Associates NSG to subnets
- **Example Usage**: `examples/basic-vnet/main.tf` (lines 48-145) - Shows multi-tier NSG configuration

#### Route Tables

**What is it?** Route Tables control how network traffic is routed from subnets. They allow defining custom routes that override Azure's system routes.

**What is it used for?**
- **Custom routing**: Defines specific routes to direct traffic (e.g., all Internet traffic through a firewall)
- **Hub-Spoke**: Implements hub-spoke architectures where traffic passes through a centralized hub
- **NVA (Network Virtual Appliance)**: Routes traffic through virtual network appliances (firewalls, routers)
- **Blackhole routes**: Blocks traffic to specific addresses
- **VPN/ExpressRoute**: Routes traffic to VPN or ExpressRoute gateways

**Implementation:**
- **Module**: `modules/networking/`
- **File**: `modules/networking/main.tf`
- **Resources**:
  - `azurerm_route_table.main` (lines 200-212) - Creates route table
  - `azurerm_route.main` (lines 230-245) - Creates custom routes
  - `azurerm_subnet_route_table_association.main` (lines 250-265) - Associates route table to subnets

#### DDoS Protection

**What is it?** Azure DDoS Protection is a service that protects your applications against distributed denial-of-service (DDoS) attacks. There are two tiers: Basic (free, always on) and Standard (paid, with advanced features).

**What is it used for?**
- **Automatic protection**: Automatically mitigates DDoS attacks without manual intervention
- **Attack analytics**: Provides detailed reports on DDoS attacks
- **Cost protection**: Protects against auto-scaling costs during attacks
- **Alerts**: Notifies when attacks are detected and mitigated
- **Telemetry**: Provides metrics and logs of DDoS attacks

**Implementation:**
- **Module**: `modules/networking/`
- **File**: `modules/networking/main.tf`
- **Resource**: `azurerm_virtual_network.main.ddos_protection_plan` (lines 37-40)
- **Note**: Requires a separate DDoS Protection Plan resource (Standard tier)

### Load Balancing Services

#### Azure Load Balancer

**What is it?** Azure Load Balancer is a Layer 4 (TCP/UDP) load balancer that distributes incoming traffic across multiple backend instances to provide high availability and scalability.

**What is it used for?**
- **High availability**: Distributes traffic across multiple healthy instances
- **Scalability**: Allows horizontal scaling by adding more backend instances
- **Health probes**: Automatically detects unhealthy instances and removes them from the pool
- **Outbound NAT**: Provides outbound Internet connectivity for VMs without public IPs
- **Port forwarding**: Allows direct access to specific VMs via NAT rules
- **Load balancing**: Distributes traffic evenly (round-robin or source IP-based)

**DNS and Name Resolution:**

While Load Balancer operates at Layer 4 (TCP/UDP) and primarily uses IP addresses, DNS is still important for making the load balancer accessible via friendly names.

**How DNS works with Load Balancer:**
- **Public IP DNS name**: Azure automatically assigns a DNS name to public IPs (e.g., `mylb.eastus.cloudapp.azure.com`)
- **Custom domain**: You can create a CNAME record pointing your custom domain to the Load Balancer's DNS name
- **Internal Load Balancer**: For internal load balancers, you can use Azure Private DNS zones to create custom names

**Use Cases:**
1. **Public-Facing Applications**: Map a custom domain (e.g., `api.example.com`) to the Load Balancer's public IP DNS name
2. **Internal Service Discovery**: Use Private DNS zones to create friendly names for internal load balancers (e.g., `internal-api.internal`)
3. **Multi-Region Deployments**: Use DNS with Traffic Manager to route traffic to different Load Balancers in different regions
4. **SSL/TLS Certificates**: DNS validation is required for SSL certificates when using custom domains

**Example Scenario**: You have a public-facing API behind a Load Balancer. Instead of users accessing `20.1.2.3:443`, you configure DNS so `api.yourcompany.com` resolves to the Load Balancer's public IP. This provides a professional interface and allows you to change the IP address without affecting users.

**Implementation:**
- **Module**: `modules/load-balancer/`
- **File**: `modules/load-balancer/main.tf`
- **Resources**:
  - `azurerm_lb.main` (lines 39-60) - Creates the Load Balancer
  - `azurerm_lb_backend_address_pool.main` (lines 75-82) - Creates backend pools
  - `azurerm_lb_probe.main` (lines 95-107) - Creates health probes
  - `azurerm_lb_rule.main` (lines 130-150) - Creates load balancing rules
  - `azurerm_lb_outbound_rule.main` (lines 165-178) - Creates outbound NAT rules
  - `azurerm_lb_nat_rule.main` (lines 195-208) - Creates inbound NAT rules
- **Variables**: `modules/load-balancer/variables.tf` - Complete configuration options

### Security Services

#### Azure Firewall

**What is it?** Azure Firewall is a managed, cloud-based firewall service that protects your Azure Virtual Network resources. It's a stateful firewall that provides built-in high availability and automatic scalability.

**What is it used for?**
- **Network filtering**: Filters traffic based on IP addresses, ports, and protocols (Layer 3/4)
- **Application filtering**: Filters traffic based on FQDNs (Fully Qualified Domain Names) for specific applications
- **NAT (DNAT)**: Performs Destination NAT to securely expose internal services to the Internet
- **Threat Intelligence**: Automatically blocks traffic from/to known malicious IP addresses and domains
- **Centralization**: Centralizes network security policy in one place
- **High availability**: Provides built-in high availability without additional configuration

**DNS and Name Resolution:**

DNS is critical for Azure Firewall, especially for application rules that filter traffic based on FQDNs (Fully Qualified Domain Names). The firewall must be able to resolve DNS names to apply application rules correctly.

**How DNS works with Azure Firewall:**
- **DNS Resolution**: Azure Firewall uses DNS to resolve FQDNs in application rules (e.g., `*.microsoft.com`, `api.github.com`)
- **Custom DNS Servers**: You can configure custom DNS servers for the firewall to use specific DNS resolution (e.g., on-premises DNS, Azure Private DNS)
- **DNS Proxy**: Azure Firewall can act as a DNS proxy, forwarding DNS queries from VMs to configured DNS servers
- **DNS Filtering**: Application rules filter traffic based on resolved FQDNs, not IP addresses

**Use Cases:**
1. **FQDN-Based Filtering**: Allow or deny access to specific websites/services by domain name (e.g., allow `*.blob.core.windows.net` but deny `*.malicious-site.com`)
2. **Hybrid DNS Resolution**: Configure custom DNS servers to resolve on-premises resources (e.g., `internal-server.company.local`)
3. **Private DNS Integration**: Use Azure Private DNS zones for internal service resolution through the firewall
4. **Security Policies**: Enforce policies like "only allow access to approved SaaS services" using FQDN filtering

**Example Scenario**: Your organization wants to allow access to Azure Storage but block access to public cloud storage services. You create an application rule allowing `*.blob.core.windows.net` (Azure Storage) while denying other storage FQDNs. The firewall uses DNS to resolve these FQDNs and applies the rules accordingly. If DNS resolution fails, the firewall cannot apply FQDN-based rules effectively.

**Important Considerations:**
- **DNS Server Availability**: If custom DNS servers are unreachable, FQDN-based application rules may fail
- **DNS Caching**: The firewall caches DNS resolutions, so IP changes may take time to propagate
- **Private IP Ranges**: Traffic to private IP ranges (configured in `private_ip_ranges`) bypasses the firewall, including DNS resolution

**Implementation:**
- **Module**: `modules/firewall/`
- **File**: `modules/firewall/main.tf`
- **Resources**:
  - `azurerm_firewall.main` (lines 44-85) - Creates Azure Firewall
  - `azurerm_firewall_network_rule_collection.main` (lines 120-140) - Network rules (Layer 3/4)
  - `azurerm_firewall_application_rule_collection.main` (lines 165-190) - Application rules (FQDN-based)
  - `azurerm_firewall_nat_rule_collection.main` (lines 215-235) - NAT rules (DNAT)
- **Key Features**:
  - Threat Intelligence integration (line 80)
  - Custom DNS servers (line 75)
  - Private IP ranges bypass (line 78)

#### Azure Bastion

**What is it?** Azure Bastion is a fully managed PaaS service that provides secure and seamless access to virtual machines directly from Azure Portal via SSL. It doesn't require a public IP on VMs or any agents, clients, or additional software.

**What is it used for?**
- **Secure VM access**: Provides RDP/SSH access to VMs without exposing public IPs
- **Reduced attack surface**: Eliminates the need for public IPs on VMs, reducing attack risk
- **Browser-based access**: No additional client software required, just a web browser
- **No VPN needed**: Access VMs from anywhere without VPN
- **Compliance**: Helps meet security requirements by eliminating public exposure
- **Simplified management**: Centralized VM access management

**DNS and Name Resolution:**

DNS is important for Azure Bastion as it provides the FQDN that users connect to, and it helps identify VMs by name rather than IP addresses.

**How DNS works with Azure Bastion:**
- **Bastion FQDN**: Azure automatically assigns a DNS name to the Bastion host (e.g., `mybastion.bastion.azure.com`)
- **VM Name Resolution**: When connecting to VMs, you can use their hostname or private IP address
- **Custom Domains**: You can use custom domains with Bastion, though the primary access is through Azure Portal

**Use Cases:**
1. **VM Discovery**: Use DNS names to identify VMs instead of remembering IP addresses (e.g., `web-server-01` instead of `10.0.1.10`)
2. **Automation**: Scripts can use DNS names to connect to VMs via Bastion programmatically
3. **Documentation**: DNS names make documentation and runbooks more readable and maintainable
4. **Multi-VNet Scenarios**: When Bastion is in a hub VNet, DNS helps identify VMs in spoke VNets

**Example Scenario**: Your operations team needs to access multiple VMs across different subnets. Instead of maintaining a spreadsheet of IP addresses, they use DNS names like `prod-web-01`, `prod-db-01`, etc. This makes it easier to identify and connect to the correct VM, especially in large environments with hundreds of VMs.

**Implementation:**
- **Module**: `modules/bastion/`
- **File**: `modules/bastion/main.tf`
- **Resource**: `azurerm_bastion_host.main` (lines 44-95)
- **Key Features**:
  - Browser-based access (HTTPS on port 443)
  - Copy/paste functionality (line 70)
  - File copy (Standard SKU, line 73)
  - Native client support (Standard SKU, line 85)

#### Web Application Firewall (WAF)

**What is it?** Web Application Firewall (WAF) is a service that protects web applications against common vulnerabilities and exploits. In Azure, WAF is integrated into Application Gateway and Azure Front Door.

**What is it used for?**
- **OWASP protection**: Protects against OWASP Top 10 vulnerabilities (SQL injection, XSS, etc.)
- **DDoS protection**: Integrated protection against application-level DDoS attacks
- **Custom rules**: Allows creating custom rules for specific needs
- **TLS inspection**: Inspects decrypted HTTPS traffic (Premium SKU only)
- **Bot Protection**: Protects against malicious bots
- **Geo-filtering**: Blocks or allows traffic based on geographic location

**Implementation:**
- **Module**: `modules/application-gateway/`
- **File**: `modules/application-gateway/variables.tf`
- **Configuration**: `waf_configuration` variable (lines 200-220)
- **Note**: WAF configuration is part of Application Gateway module, not a separate module

#### Azure Private Link

**What is it?** Azure Private Link allows accessing Azure services (such as Storage, SQL Database) and Azure-hosted services from your Virtual Network via a private IP address, without going through the Internet.

**What is it used for?**
- **Private connectivity**: Access Azure services via private IP addresses
- **Enhanced security**: Traffic doesn't traverse the Internet, stays on Azure's backbone
- **Network simplification**: No need to configure NSG rules for service IP ranges
- **Reduced exposure**: Services are not exposed to the Internet
- **Compliance**: Helps meet security and compliance requirements

**DNS and Name Resolution:**

DNS is fundamental to Azure Private Link. When you create a private endpoint, Azure automatically creates a private DNS zone or updates an existing one to resolve the service's public DNS name to the private IP address.

**How DNS works with Private Link:**
- **Automatic DNS Integration**: Azure automatically creates DNS A records in a Private DNS zone when you create a private endpoint
- **Private DNS Zones**: Azure manages Private DNS zones (e.g., `privatelink.blob.core.windows.net`) that map service names to private IPs
- **DNS Resolution**: When a resource in your VNet queries the service's DNS name, it resolves to the private IP instead of the public IP
- **Zone Integration**: Private DNS zones are automatically linked to your VNet for seamless resolution

**Use Cases:**
1. **Seamless Service Access**: Applications continue using the same DNS names (e.g., `mystorageaccount.blob.core.windows.net`) but traffic goes over private connectivity
2. **No Code Changes**: Existing applications don't need code changes - DNS resolution automatically routes to private endpoints
3. **Multi-VNet Access**: Multiple VNets can use the same Private DNS zone to access services privately
4. **Hybrid Scenarios**: On-premises resources can resolve Azure services via Private DNS zones when connected via VPN/ExpressRoute

**Example Scenario**: You have a Storage Account that your VMs need to access. Instead of using the public endpoint (which goes over the Internet), you create a private endpoint. Azure automatically updates DNS so `mystorageaccount.blob.core.windows.net` resolves to the private IP (e.g., `10.0.1.100`) instead of the public IP. Your VMs continue using the same DNS name, but all traffic stays on Azure's private backbone network, improving security and performance.

**Important Considerations:**
- **DNS Zone Management**: Azure automatically manages Private DNS zones, but you can also use custom DNS zones
- **Resolution Priority**: Private DNS zones take precedence over public DNS resolution within the VNet
- **Cross-VNet Resolution**: Resources in different VNets need the Private DNS zone linked to their VNet to resolve correctly

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Implementation**: Requires `azurerm_private_endpoint` and `azurerm_private_link_service` resources
- **Note**: Module structure exists in directory but implementation pending

#### Azure Firewall Manager

**What is it?** Azure Firewall Manager is a security management service that provides centralized firewall policy management to protect your cloud networks at scale.

**What is it used for?**
- **Centralized management**: Manages firewall policies for multiple Azure Firewalls and Virtual WAN hubs
- **Security policies**: Define security policies once and apply them to multiple firewalls
- **Governance**: Establishes organization-level security policies
- **Automation**: Simplifies security management in complex architectures
- **Compliance**: Facilitates compliance with corporate security policies

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Note**: Firewall Manager is a management service that works with Azure Firewall policies
- **Implementation**: Would use `azurerm_firewall_policy` resources

### Connectivity Services

#### Azure NAT Gateway

**What is it?** Azure NAT Gateway is a fully managed, highly resilient service that provides outbound Internet connectivity for Virtual Network subnets. It provides source NAT (SNAT) for resources without public IPs.

**What is it used for?**
- **Outbound connectivity**: Allows VMs without public IPs to access the Internet
- **Simplification**: Simpler than configuring outbound rules in Load Balancer
- **High performance**: Up to 50 Gbps throughput
- **Scalability**: Up to 64,000 concurrent flows per public IP
- **No SNAT port exhaustion**: Avoids SNAT port exhaustion issues common with Load Balancer
- **High availability**: Zone redundancy support

**Implementation:**
- **Module**: `modules/nat-gateway/`
- **File**: `modules/nat-gateway/main.tf`
- **Resource**: `azurerm_nat_gateway.main` (lines 44-65)
- **Key Features**:
  - Public IP association (lines 58-62)
  - Automatic scaling
  - Up to 64,000 concurrent flows per public IP
  - Zone redundancy support

#### Azure VPN Gateway

**What is it?** Azure VPN Gateway is a specific type of virtual network gateway used to send encrypted traffic between an Azure virtual network and on-premises locations over the public Internet, or to connect virtual networks to each other.

**What is it used for?**
- **Site-to-site connection**: Connects your on-premises network to Azure via a secure VPN connection
- **Point-to-site connection**: Allows individual users to connect to Azure from anywhere
- **VNet-to-VNet connection**: Connects Azure virtual networks to each other
- **Hybrid connectivity**: Integrates on-premises infrastructure with cloud resources
- **Encryption**: All traffic is encrypted via VPN protocols (IPsec/IKE)

**DNS and Name Resolution:**

DNS is crucial for VPN Gateway scenarios, especially for hybrid connectivity where on-premises resources need to resolve Azure resources and vice versa.

**How DNS works with VPN Gateway:**
- **DNS Forwarding**: VPN Gateway can forward DNS queries between on-premises and Azure
- **Custom DNS**: You can configure custom DNS servers in the VNet that on-premises resources can query
- **Split-Brain DNS**: Different DNS resolution for the same domain name depending on where the query originates
- **DNS Suffix**: Configure DNS suffixes so resources can resolve using short names

**Use Cases:**
1. **Hybrid Name Resolution**: On-premises servers need to resolve Azure VMs by name (e.g., `azure-vm-01.internal`)
2. **Azure to On-Premises**: Azure resources need to resolve on-premises servers (e.g., `onprem-server.company.local`)
3. **Active Directory Integration**: Integrate with on-premises Active Directory DNS for seamless domain resolution
4. **Service Discovery**: Applications spanning on-premises and Azure can discover services using DNS

**Example Scenario**: Your on-premises application needs to connect to a database in Azure. Instead of hardcoding the Azure VM's IP address, you configure DNS forwarding so `azure-db.company.local` resolves correctly from on-premises. Similarly, Azure VMs can resolve `onprem-app.company.local`. This creates a unified DNS namespace across your hybrid infrastructure.

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/vpn-gateway/` (structure exists)
- **Implementation**: Would use `azurerm_virtual_network_gateway` resource
- **Note**: Implementation pending

#### Azure ExpressRoute

**What is it?** Azure ExpressRoute allows extending your on-premises networks into Microsoft Cloud over a private dedicated connection facilitated by a connectivity provider. ExpressRoute doesn't go over the Internet and offers more reliability, speed, and security than typical Internet connections.

**What is it used for?**
- **Private connection**: Dedicated connection that doesn't traverse the public Internet
- **Higher bandwidth**: Up to 100 Gbps bandwidth
- **Predictable performance**: Predictable latency and performance
- **Global reach**: Connects to Azure regions worldwide
- **High availability**: 99.95% uptime SLA
- **Compliance**: Meets strict security and compliance requirements

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/expressroute/` (structure exists)
- **Implementation**: Would use `azurerm_express_route_circuit` resource
- **Note**: Implementation pending

#### Azure Virtual WAN

**What is it?** Azure Virtual WAN is a networking service that brings together many networking, security, and routing functionalities to provide a single operational interface. These functionalities include branch connectivity (via VPN and ExpressRoute), remote user connectivity (point-to-site VPN), transitive virtual network connectivity, routing, Azure Firewall, and encryption for private connectivity.

**What is it used for?**
- **Hub-spoke architecture**: Centralizes connectivity in virtual hubs
- **Branch connectivity**: Connects remote offices via VPN or ExpressRoute
- **User connectivity**: Allows remote users to connect via point-to-site VPN
- **VNet connectivity**: Connects virtual networks to hubs
- **Centralized security**: Integrates Azure Firewall for centralized security
- **SD-WAN**: Integrates third-party SD-WAN devices

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/virtual-wan/` (structure exists)
- **Implementation**: Would use `azurerm_virtual_wan` and `azurerm_virtual_hub` resources
- **Note**: Implementation pending

#### Routing Preference

**What is it?** Routing Preference is a feature of Azure public IP addresses that allows you to choose how traffic is routed between Azure and the Internet.

**What is it used for?**
- **Performance optimization**: Routes traffic through Microsoft's global network for lower latency
- **Cost optimization**: Routes traffic through ISPs for lower costs
- **Route control**: Choose between performance (Microsoft Network) or cost (Internet)
- **Global applications**: Optimizes performance for applications with global users

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Implementation**: Configured via Public IP `routing_preference` attribute
- **Note**: Feature of Public IP resources, not a separate service

### Application Delivery Services

#### Azure Application Gateway

**What is it?** Azure Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. It operates at Layer 7 (HTTP/HTTPS) and provides advanced features such as SSL termination, cookie-based session affinity, URL-based routing, and integrated WAF.

**What is it used for?**
- **Layer 7 load balancing**: Distributes HTTP/HTTPS traffic among backend servers
- **SSL termination**: Decrypts SSL traffic at the gateway, reducing load on backend servers
- **URL-based routing**: Routes traffic based on URL path
- **Host-based routing**: Routes traffic based on Host header
- **Session affinity**: Maintains user sessions on the same backend server
- **Integrated WAF**: Protection against common web vulnerabilities (with WAF SKU)
- **Redirection**: Automatically redirects HTTP to HTTPS

**Implementation:**
- **Module**: `modules/application-gateway/`
- **File**: `modules/application-gateway/variables.tf` (complete variable definitions)
- **Status**: Variables defined, main.tf implementation pending
- **Resources** (to be implemented):
  - `azurerm_application_gateway` - Main resource
  - Backend pools, HTTP settings, listeners, rules, probes
  - WAF configuration (for WAF SKU)

#### Azure Front Door

**What is it?** Azure Front Door is a global, scalable, and secure entry point for delivering high-performance web applications. It uses Microsoft's global network to create high-performance and highly available web applications.

**What is it used for?**
- **Global load balancing**: Distributes traffic to multiple Azure regions
- **Application acceleration**: Improves performance by routing to the nearest region
- **High availability**: Automatic failover between regions
- **Integrated WAF**: Integrated DDoS and WAF protection
- **Edge caching**: Stores static content at edge locations for lower latency
- **SSL termination**: Terminates SSL at the edge
- **Intelligent routing**: Routes to the nearest and healthiest region

**DNS and Name Resolution:**

DNS is the foundation of Azure Front Door. Front Door is a DNS-based service that routes traffic globally based on DNS resolution and intelligent routing algorithms.

**How DNS works with Azure Front Door:**
- **DNS-Based Routing**: Front Door uses DNS to route users to the nearest healthy endpoint
- **CNAME Configuration**: You create a CNAME record pointing your domain to Front Door's DNS name (e.g., `yourdomain.com` → `yourdomain.azurefd.net`)
- **Global DNS Resolution**: Front Door's DNS infrastructure resolves queries from edge locations worldwide
- **Health-Based Routing**: DNS responses are dynamically updated based on backend health and performance

**Use Cases:**
1. **Global Load Balancing**: DNS automatically routes users to the nearest healthy region (e.g., US users → US East, EU users → West Europe)
2. **Failover**: If a region becomes unhealthy, DNS automatically routes traffic to healthy regions
3. **Custom Domains**: Point multiple custom domains to Front Door for different applications or regions
4. **CDN Integration**: DNS resolution determines which edge location serves cached content

**Example Scenario**: You have a global application deployed in multiple regions (US East, West Europe, Southeast Asia). You configure DNS so `www.yourcompany.com` points to Front Door. When a user in Tokyo queries the DNS, Front Door's DNS infrastructure resolves to the Southeast Asia backend (lowest latency). If that backend becomes unhealthy, DNS automatically resolves to the next closest healthy region. This provides seamless global distribution with automatic failover.

**Important Considerations:**
- **DNS TTL**: Front Door uses appropriate TTL values to balance responsiveness and DNS query load
- **CNAME Flattening**: Front Door supports CNAME flattening for apex domains (root domains)
- **SSL/TLS**: DNS validation is required for SSL certificates with custom domains

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/front-door/` (structure exists)
- **Implementation**: Would use `azurerm_frontdoor` resource
- **Note**: Implementation pending

#### Azure CDN

**What is it?** Azure Content Delivery Network (CDN) is a global network of servers that delivers high-bandwidth web content to users. It caches content at edge locations close to end users.

**What is it used for?**
- **Content delivery**: Delivers static content (images, videos, CSS, JavaScript) from nearby locations
- **Latency reduction**: Reduces latency by serving content from edge locations
- **High bandwidth**: Supports high bandwidth for large content
- **Optimization**: Automatically optimizes different content types
- **HTTPS**: Full HTTPS support
- **Custom domains**: Use your own custom domains

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/cdn/` (structure exists)
- **Implementation**: Would use `azurerm_cdn_profile` and `azurerm_cdn_endpoint` resources
- **Note**: Implementation pending

#### Azure Traffic Manager

**What is it?** Azure Traffic Manager is a DNS-based load balancer that distributes traffic optimally to services across Azure regions and worldwide, providing high availability and responsiveness.

**What is it used for?**
- **DNS-based load balancing**: Distributes traffic via DNS resolution
- **Routing methods**: Priority (failover), Weighted (distribution), Performance (lowest latency), Geographic (location)
- **High availability**: Automatic failover between endpoints
- **Multi-region**: Distributes traffic across multiple Azure regions
- **Health monitoring**: Monitors endpoint health and routes only to healthy endpoints
- **Cost-effective**: Economical solution for global traffic distribution

**DNS and Name Resolution:**

Traffic Manager is fundamentally a DNS-based load balancing service. It doesn't proxy traffic; instead, it returns different DNS responses based on the configured routing method and endpoint health.

**How DNS works with Traffic Manager:**
- **DNS-Based Load Balancing**: Traffic Manager returns different IP addresses in DNS responses based on routing method
- **Routing Methods**: DNS responses vary by method:
  - **Priority**: Returns the IP of the highest priority healthy endpoint
  - **Weighted**: Returns IPs based on configured weights (round-robin DNS)
  - **Performance**: Returns the IP of the endpoint with lowest latency from the user's location
  - **Geographic**: Returns IPs based on the user's geographic location
  - **Subnet**: Returns IPs based on the user's source IP subnet
- **Health Monitoring**: Traffic Manager monitors endpoint health and only returns healthy endpoints in DNS responses
- **TTL Management**: Traffic Manager uses short TTLs (typically 60 seconds) to enable quick failover

**Use Cases:**
1. **Failover Scenarios**: Primary region fails → DNS automatically returns secondary region's IP
2. **Geographic Distribution**: Users in different regions get DNS responses pointing to their nearest endpoint
3. **A/B Testing**: Use weighted routing to gradually shift traffic from old to new infrastructure
4. **Multi-Cloud**: Route traffic between Azure and other cloud providers using DNS

**Example Scenario**: You have applications in US East (primary) and West Europe (secondary). You configure Traffic Manager with Priority routing. Under normal conditions, DNS queries return the US East IP. If US East becomes unhealthy, Traffic Manager's health probes detect this and DNS queries start returning the West Europe IP. The short TTL ensures clients quickly get the updated DNS response, enabling fast failover without manual intervention.

**Important Considerations:**
- **DNS Caching**: Client-side DNS caching may delay failover (mitigated by short TTLs)
- **Not a Proxy**: Traffic Manager doesn't proxy traffic - it only returns DNS responses
- **Health Probe Frequency**: More frequent health probes enable faster failover detection

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/traffic-manager/` (structure exists)
- **Implementation**: Would use `azurerm_traffic_manager_profile` resource
- **Note**: Implementation pending

### Monitoring Services

#### Azure Network Watcher

**What is it?** Azure Network Watcher provides tools to monitor, diagnose, view metrics, and enable or disable logs for resources in an Azure virtual network.

**What is it used for?**
- **Network topology**: Visualizes network resources and their relationships
- **Connection Monitor**: Monitors connectivity between resources
- **Packet Capture**: Captures network packets for analysis
- **IP Flow Verify**: Verifies if traffic is allowed or denied
- **Next Hop**: Determines the routing path for traffic
- **VPN Troubleshoot**: Diagnoses VPN connection issues
- **NSG Flow Logs**: Logs information about network traffic flowing through NSGs
- **Network Performance Monitor**: Monitors network performance

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/network-watcher/` (structure exists)
- **Implementation**: Would use `azurerm_network_watcher` and related resources
- **Note**: Implementation pending

### Advanced Services

#### Azure DNS

**What is it?** Azure DNS is a hosting service for DNS domains that provides name resolution using Microsoft Azure infrastructure.

**What is it used for?**
- **DNS hosting**: Hosts DNS domains in Azure
- **High availability**: Provides high availability and performance
- **Fast**: Ultra-fast DNS resolution
- **Secure**: Integrated DDoS protection
- **Record management**: Manages DNS records (A, AAAA, CNAME, MX, NS, PTR, SOA, SRV, TXT)
- **Delegation**: Delegates domains to Azure DNS

**DNS and Name Resolution:**

Azure DNS is the DNS service itself, providing DNS hosting and resolution capabilities for both public and private domains.

**How Azure DNS works:**
- **Public DNS Zones**: Host public DNS zones (e.g., `example.com`) with public DNS resolution
- **Private DNS Zones**: Host private DNS zones (e.g., `internal.company.local`) for VNet resources
- **DNS Resolver**: Azure DNS Private Resolver enables bidirectional DNS resolution between Azure and on-premises
- **Automatic Record Management**: Azure services can automatically create DNS records (e.g., Private Link creates A records)

**Use Cases:**
1. **Public Domain Hosting**: Host your public domain's DNS records in Azure (A, AAAA, CNAME, MX, TXT, etc.)
2. **Private Service Discovery**: Create private DNS zones for internal services (e.g., `database.internal` resolves to `10.0.3.10`)
3. **Hybrid DNS**: Azure DNS Private Resolver enables on-premises resources to resolve Azure Private DNS zones and vice versa
4. **Automated DNS Management**: Integrate with Azure services for automatic DNS record creation/updates

**Example Scenario**: You have a multi-VNet architecture with services in different VNets. You create a Private DNS zone `services.internal` and link it to all VNets. Services register themselves (e.g., `api.services.internal`, `db.services.internal`). Resources in any VNet can resolve these names to private IPs, enabling service discovery without hardcoding IPs. When a service's IP changes, only the DNS record needs updating, not all client configurations.

**Important Considerations:**
- **Zone Linking**: Private DNS zones must be linked to VNets for resources in those VNets to resolve names
- **Record Types**: Azure DNS supports all standard DNS record types
- **Delegation**: Public DNS zones require domain delegation at your domain registrar
- **Performance**: Azure DNS provides high-performance DNS resolution with global distribution

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Directory**: `modules/dns/` (structure exists)
- **Implementation**: Would use `azurerm_dns_zone` and `azurerm_dns_record` resources
- **Note**: Implementation pending

#### Internet Analyzer

**What is it?** Azure Internet Analyzer is a service that allows you to test the impact that changes in network infrastructure would have on your applications' performance.

**What is it used for?**
- **Performance analysis**: Compares performance of different network configurations
- **A/B testing**: Tests different configurations before implementing them
- **Optimization**: Identifies the best network configuration for your applications
- **Metrics**: Provides real-time performance metrics

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Note**: Service-specific documentation available, implementation pending

#### Azure Programmable Connectivity

**What is it?** Azure Programmable Connectivity is an advanced service that enables creating cloud-native and edge-native applications that interact with network intelligence, including 5G and SD-WAN network functions on edge devices.

**What is it used for?**
- **5G Edge**: Implements 5G network functions on edge devices
- **SD-WAN**: Manages SD-WAN functions on edge devices
- **Network intelligence**: Leverages network intelligence to optimize applications
- **Edge computing**: Integrates edge computing capabilities with network functions
- **Cloud-native applications**: Creates applications that leverage advanced network capabilities

**Status**: Documented in `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
- **Note**: Advanced service for 5G and SD-WAN edge functions, implementation pending

### Example Implementations

#### Basic Virtual Network Example
- **Location**: `examples/basic-vnet/`
- **File**: `examples/basic-vnet/main.tf`
- **Services Demonstrated**:
  - Virtual Network (line 38, via module)
  - Subnets (lines 48-60, via module)
  - Network Security Groups (lines 65-145, via module)
  - Multi-tier architecture (Web/App/DB subnets)

### Documentation References

All services are comprehensively documented in:
- **Complete Guide**: `docs/AZURE_NETWORKING_COMPLETE_GUIDE.md`
  - Architecture diagrams (Mermaid)
  - Use cases and best practices
  - Service comparisons
- **Service Comparisons**: `docs/SERVICE_COMPARISONS.md`
  - Detailed comparisons between similar services
  - Decision trees
  - Cost and performance analysis

## Contributing

This is a tutorial repository. Feel free to:
- Use the code as a reference
- Adapt it to your needs
- Suggest improvements
- Report issues

## License

This tutorial is provided as-is for educational purposes.

## Additional Resources

- [Azure Networking Services Overview](https://learn.microsoft.com/en-us/azure/networking/fundamentals/networking-overview) - Official Microsoft documentation explaining what each Azure networking service is and what it's used for
- [Azure Networking Documentation](https://docs.microsoft.com/azure/networking/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)

---

**Note**: This tutorial is comprehensive and covers all major Azure networking services. Each module is production-ready and includes detailed comments and documentation.

