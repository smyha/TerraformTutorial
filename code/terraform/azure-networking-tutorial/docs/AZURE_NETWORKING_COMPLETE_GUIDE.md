# Azure Networking Complete Guide with Terraform

## Table of Contents

1. [Introduction](#introduction)
2. [Core Networking Services](#core-networking-services)
3. [Load Balancing and Traffic Management](#load-balancing-and-traffic-management)
4. [Security Services](#security-services)
5. [Connectivity Services](#connectivity-services)
6. [Application Delivery Services](#application-delivery-services)
7. [Monitoring and Management](#monitoring-and-management)
8. [Best Practices](#best-practices)
9. [Architecture Patterns](#architecture-patterns)

---

## Introduction

Azure Networking provides a comprehensive set of services to connect, protect, and optimize your cloud infrastructure. This guide covers all major Azure networking services and how to implement them with Terraform.

### Azure Networking Services Overview

```mermaid
graph TB
    subgraph "Core Networking"
        VNet[Azure Virtual Network]
        Subnet[Subnets]
        NSG[Network Security Groups]
        RouteTable[Route Tables]
    end
    
    subgraph "Load Balancing"
        LB[Azure Load Balancer]
        AppGW[Application Gateway]
        FrontDoor[Azure Front Door]
        TrafficMgr[Traffic Manager]
    end
    
    subgraph "Security"
        Firewall[Azure Firewall]
        WAF[Web Application Firewall]
        Bastion[Azure Bastion]
        PrivateLink[Azure Private Link]
        DDoS[DDoS Protection]
    end
    
    subgraph "Connectivity"
        VPN[VPN Gateway]
        ExpressRoute[ExpressRoute]
        VirtualWAN[Virtual WAN]
        NAT[NAT Gateway]
    end
    
    subgraph "Application Delivery"
        CDN[Azure CDN]
        FrontDoor2[Azure Front Door]
        AppGW2[Application Gateway]
    end
    
    subgraph "Monitoring"
        NW[Network Watcher]
        Monitor[Azure Monitor]
    end
    
    VNet --> Subnet
    Subnet --> NSG
    Subnet --> RouteTable
    VNet --> LB
    VNet --> Firewall
    VNet --> VPN
    VNet --> ExpressRoute
```

---

## Core Networking Services

### Azure Virtual Network (VNet)

Azure Virtual Network is the fundamental building block for your private network in Azure.

#### What is a VNet?

A VNet is a representation of your own network in the cloud. It logically isolates your Azure resources from each other and from the internet.

#### Key Features

- **Network Isolation**: Complete isolation from other VNets
- **IP Address Management**: Define your own private IP address space
- **Subnet Segmentation**: Divide your network into subnets
- **DNS Resolution**: Built-in DNS or custom DNS servers
- **Service Integration**: Connect to Azure services via service endpoints

#### Architecture

```mermaid
graph LR
    subgraph "Azure Virtual Network (10.0.0.0/16)"
        Subnet1[Web Subnet<br/>10.0.1.0/24]
        Subnet2[App Subnet<br/>10.0.2.0/24]
        Subnet3[DB Subnet<br/>10.0.3.0/24]
        Subnet4[Gateway Subnet<br/>10.0.4.0/24]
    end
    
    Subnet1 --> NSG1[NSG: Web]
    Subnet2 --> NSG2[NSG: App]
    Subnet3 --> NSG3[NSG: DB]
    
    Subnet1 --> RouteTable1[Route Table]
    Subnet2 --> RouteTable2[Route Table]
```

#### Terraform Example

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
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    "app-subnet" = {
      address_prefixes = ["10.0.2.0/24"]
    }
    "db-subnet" = {
      address_prefixes = ["10.0.3.0/24"]
    }
  }
  
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
      ]
      associate_to_subnets = ["web-subnet"]
    }
  }
}
```

#### Best Practices

1. **Address Space Planning**: Use non-overlapping CIDR blocks
2. **Subnet Sizing**: Plan for future growth (don't use /30 subnets)
3. **Service Endpoints**: Enable for Azure services to improve security
4. **NSG Rules**: Follow least privilege principle
5. **Route Tables**: Use for hub-spoke architectures

---

### Network Security Groups (NSGs)

NSGs act as a distributed firewall at the network level.

#### NSG Rule Evaluation

```mermaid
flowchart TD
    Start[Traffic Arrives] --> CheckNSG{NSG<br/>Associated?}
    CheckNSG -->|No| Allow[Allow Traffic]
    CheckNSG -->|Yes| CheckRule{Match<br/>Rule?}
    CheckRule -->|Yes| CheckAction{Action?}
    CheckAction -->|Allow| Allow
    CheckAction -->|Deny| Deny[Deny Traffic]
    CheckRule -->|No| DefaultRule{Default<br/>Rule?}
    DefaultRule -->|Inbound| Deny
    DefaultRule -->|Outbound| Allow
```

#### NSG Rule Priority

- Lower number = Higher priority
- First matching rule wins
- Default rules (65000+) are evaluated last

---

## Load Balancing and Traffic Management

### Azure Load Balancer

Azure Load Balancer provides high availability and network performance for your applications.

#### Load Balancer Types

```mermaid
graph TB
    subgraph "Public Load Balancer"
        Internet[Internet]
        PublicLB[Public Load Balancer<br/>Public IP]
        PublicLB --> Backend1[VM 1]
        PublicLB --> Backend2[VM 2]
        PublicLB --> Backend3[VM 3]
        Internet --> PublicLB
    end
    
    subgraph "Internal Load Balancer"
        VNet[Virtual Network]
        InternalLB[Internal Load Balancer<br/>Private IP]
        InternalLB --> AppVM1[App VM 1]
        InternalLB --> AppVM2[App VM 2]
        VNet --> InternalLB
    end
```

#### Load Balancer Features

- **Layer 4 Load Balancing**: TCP/UDP
- **Health Probes**: Automatic health checking
- **High Availability**: Built-in redundancy
- **Outbound Rules**: SNAT for backend VMs
- **Inbound NAT Rules**: Port forwarding

#### Load Distribution Methods

1. **Round Robin**: Even distribution (default)
2. **Source IP Affinity**: Sticky sessions (5-tuple hash)

#### Terraform Example

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
      zones                = ["1", "2", "3"]
    }
  ]
  
  backend_address_pools = [
    {
      name = "web-backend-pool"
    }
  ]
  
  probe_configurations = [
    {
      name                = "http-probe"
      protocol            = "Http"
      port                = 80
      request_path        = "/health"
      interval_in_seconds = 5
      number_of_probes    = 2
    }
  ]
  
  load_balancing_rules = [
    {
      name                           = "http-rule"
      frontend_ip_configuration_name = "public-frontend"
      backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
      probe_id                       = azurerm_lb_probe.http.id
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
    }
  ]
}
```

---

### Azure Application Gateway

Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications.

#### Application Gateway Features

```mermaid
graph TB
    Client[Client] --> AppGW[Application Gateway<br/>Layer 7]
    AppGW --> WAF[Web Application<br/>Firewall]
    WAF --> Backend1[Backend Pool 1<br/>Web Servers]
    WAF --> Backend2[Backend Pool 2<br/>API Servers]
    
    AppGW --> SSL[SSL Termination]
    AppGW --> Cookie[Session Affinity]
    AppGW --> Path[Path-based Routing]
    AppGW --> Host[Host-based Routing]
```

#### Key Features

- **Layer 7 Load Balancing**: HTTP/HTTPS
- **SSL/TLS Termination**: Offload SSL processing
- **Web Application Firewall**: Built-in WAF
- **URL-based Routing**: Route based on URL path
- **Multi-site Hosting**: Host multiple sites
- **Redirection**: HTTP to HTTPS redirection
- **Session Affinity**: Cookie-based affinity

#### SKU Comparison

| Feature | Standard | WAF | Standard_v2 | WAF_v2 |
|---------|----------|-----|-------------|--------|
| Autoscaling | No | No | Yes | Yes |
| Zone Redundancy | No | No | Yes | Yes |
| Performance | Fixed | Fixed | Variable | Variable |
| WAF | No | Yes | No | Yes |
| Cost | Lower | Medium | Medium | Higher |

---

### Azure Front Door

Azure Front Door is a global, scalable entry point that uses the Microsoft global network.

#### Front Door Architecture

```mermaid
graph TB
    Users[Users Worldwide] --> FrontDoor[Azure Front Door<br/>Global Network]
    FrontDoor --> Origin1[Origin 1<br/>East US]
    FrontDoor --> Origin2[Origin 2<br/>West Europe]
    FrontDoor --> Origin3[Origin 3<br/>Southeast Asia]
    
    FrontDoor --> WAF2[WAF Protection]
    FrontDoor --> SSL2[SSL Termination]
    FrontDoor --> Cache[Edge Caching]
```

#### Front Door Features

- **Global Load Balancing**: Route to closest healthy backend
- **WAF Integration**: DDoS and WAF protection
- **SSL/TLS Termination**: At the edge
- **Caching**: Static content caching at edge locations
- **URL Rewrite**: Modify request/response URLs
- **Health Probes**: Automatic health checking

#### Use Cases

1. **Global Applications**: Serve users worldwide
2. **Multi-region Deployments**: Active-active setups
3. **Disaster Recovery**: Automatic failover
4. **Performance Optimization**: Route to closest region

---

### Azure Traffic Manager

Traffic Manager is a DNS-based traffic load balancer.

#### Traffic Routing Methods

```mermaid
graph TB
    DNS[DNS Query] --> TM[Traffic Manager]
    TM --> Priority[Priority<br/>Failover]
    TM --> Weighted[Weighted<br/>Distribution]
    TM --> Performance[Performance<br/>Lowest Latency]
    TM --> Geographic[Geographic<br/>Location-based]
    TM --> Subnet[Subnet<br/>IP-based]
    TM --> MultiValue[MultiValue<br/>Multiple IPs]
```

#### Routing Methods

1. **Priority**: Failover (primary → secondary)
2. **Weighted**: Distribute by weight percentage
3. **Performance**: Route to lowest latency endpoint
4. **Geographic**: Route based on user location
5. **Subnet**: Route based on source IP subnet
6. **MultiValue**: Return multiple healthy endpoints

---

## Security Services

### Azure Firewall

Azure Firewall is a managed, cloud-based network security service.

#### Firewall Architecture

```mermaid
graph TB
    Internet[Internet] --> PublicIP[Public IP]
    PublicIP --> Firewall[Azure Firewall]
    Firewall --> NAT[NAT Rules<br/>DNAT]
    Firewall --> Network[Network Rules<br/>Layer 3/4]
    Firewall --> App[Application Rules<br/>FQDN Filtering]
    Firewall --> ThreatIntel[Threat Intelligence]
    Firewall --> PrivateSubnet[Private Subnet<br/>VMs]
```

#### Firewall Rule Types

1. **Network Rules**: Filter by IP, port, protocol
2. **Application Rules**: Filter by FQDN
3. **NAT Rules**: Destination NAT (DNAT)

#### SKU Comparison

| Feature | Standard | Premium |
|---------|----------|---------|
| Throughput | 2.5 Gbps | 30 Gbps |
| Network Rules | Yes | Yes |
| Application Rules | Yes | Yes |
| NAT Rules | Yes | Yes |
| Threat Intelligence | Yes | Yes |
| TLS Inspection | No | Yes |
| IDPS | No | Yes |
| URL Filtering | Basic | Advanced |

---

### Azure Bastion

Azure Bastion provides secure RDP/SSH access to VMs without public IPs.

#### Bastion Architecture

```mermaid
sequenceDiagram
    participant User
    participant Browser
    participant Bastion
    participant VM
    
    User->>Browser: Navigate to Azure Portal
    Browser->>Bastion: Connect via HTTPS (443)
    Bastion->>VM: RDP/SSH (3389/22)
    VM->>Bastion: Session Established
    Bastion->>Browser: Encrypted Tunnel
    Browser->>User: Remote Desktop/SSH
```

#### Bastion Benefits

- **No Public IPs**: VMs don't need public IPs
- **No VPN Required**: Access from anywhere
- **Browser-based**: No client software needed
- **Secure**: All traffic encrypted
- **NSG Integration**: Uses NSG rules

---

### Azure Private Link

Private Link provides private connectivity to Azure services.

#### Private Link Architecture

```mermaid
graph TB
    VNet1[Virtual Network 1] --> PrivateEndpoint1[Private Endpoint]
    VNet2[Virtual Network 2] --> PrivateEndpoint2[Private Endpoint]
    PrivateEndpoint1 --> PrivateLinkService[Private Link Service]
    PrivateEndpoint2 --> PrivateLinkService
    PrivateLinkService --> Service[Azure Service<br/>Storage/SQL/etc.]
    
    Internet -.->|Blocked| Service
    VNet1 -.->|Private| Service
    VNet2 -.->|Private| Service
```

#### Private Link Benefits

- **Private Connectivity**: Traffic stays on Azure backbone
- **No Public Exposure**: Services not exposed to internet
- **Simplified Networking**: No NSG rules for service IPs
- **Global Reach**: Connect across regions

---

### Azure DDoS Protection

DDoS Protection protects against distributed denial-of-service attacks.

#### DDoS Protection Tiers

```mermaid
graph TB
    Attack[DDoS Attack] --> Basic[Basic Protection<br/>Always On]
    Attack --> Standard[Standard Protection<br/>Adaptive Tuning]
    
    Basic --> Mitigation1[Automatic Mitigation]
    Standard --> Mitigation2[Advanced Mitigation]
    Standard --> Alerting[Attack Analytics]
    Standard --> CostProtection[Cost Protection]
```

#### Protection Tiers

1. **Basic**: Always-on, automatic mitigation (free)
2. **Standard**: Advanced features, attack analytics, cost protection (paid)

---

## Connectivity Services

### Azure VPN Gateway

VPN Gateway connects your on-premises network to Azure via site-to-site or point-to-site VPN.

#### VPN Gateway Types

```mermaid
graph TB
    subgraph "Site-to-Site VPN"
        OnPrem1[On-Premises<br/>Network 1] --> VPN1[VPN Gateway]
        OnPrem2[On-Premises<br/>Network 2] --> VPN1
        VPN1 --> VNet[Azure VNet]
    end
    
    subgraph "Point-to-Site VPN"
        User[Remote User] --> P2S[Point-to-Site<br/>VPN]
        P2S --> VNet
    end
    
    subgraph "VNet-to-VNet"
        VNet1[VNet 1] --> VPN2[VPN Gateway]
        VPN2 --> VNet2[VNet 2]
    end
```

#### VPN Gateway SKUs

| SKU | Throughput | Tunnels | BGP |
|-----|------------|---------|-----|
| Basic | 100 Mbps | 10 | No |
| VpnGw1 | 650 Mbps | 30 | Yes |
| VpnGw2 | 1 Gbps | 30 | Yes |
| VpnGw3 | 1.25 Gbps | 30 | Yes |
| VpnGw4 | 5 Gbps | 100 | Yes |
| VpnGw5 | 10 Gbps | 100 | Yes |

---

### Azure ExpressRoute

ExpressRoute provides private connectivity to Azure via a dedicated connection.

#### ExpressRoute Architecture

```mermaid
graph TB
    OnPrem[On-Premises<br/>Network] --> Provider[Connectivity Provider<br/>ISP/Carrier]
    Provider --> Microsoft[Microsoft Edge<br/>Peering Location]
    Microsoft --> Azure[Azure Services]
    
    OnPrem --> Provider2[Secondary Provider<br/>Redundancy]
    Provider2 --> Microsoft2[Secondary Peering<br/>Location]
    Microsoft2 --> Azure
```

#### ExpressRoute Benefits

- **Private Connection**: Dedicated, not over internet
- **Higher Bandwidth**: Up to 100 Gbps
- **Lower Latency**: Predictable performance
- **Global Reach**: Connect to Azure regions worldwide
- **SLA**: 99.95% uptime SLA

#### Peering Types

1. **Azure Private Peering**: Connect to Azure VNets
2. **Microsoft Peering**: Connect to Microsoft 365, Azure services
3. **Azure Public Peering**: (Deprecated)

---

### Azure Virtual WAN

Virtual WAN is a networking service that brings many networking, security, and routing functionalities together.

#### Virtual WAN Architecture

```mermaid
graph TB
    Branch1[Branch Office 1] --> Hub1[Virtual Hub 1]
    Branch2[Branch Office 2] --> Hub1
    VNet1[VNet 1] --> Hub1
    VNet2[VNet 2] --> Hub1
    
    Hub1 --> Hub2[Virtual Hub 2<br/>Different Region]
    Hub2 --> Branch3[Branch Office 3]
    Hub2 --> VNet3[VNet 3]
    
    Hub1 --> Firewall3[Azure Firewall]
    Hub2 --> Firewall4[Azure Firewall]
```

#### Virtual WAN Features

- **Hub and Spoke**: Centralized connectivity
- **Branch Connectivity**: VPN, ExpressRoute
- **VNet Connectivity**: Connect VNets to hubs
- **Firewall Integration**: Centralized security
- **SD-WAN Integration**: Third-party SD-WAN devices

---

### Azure NAT Gateway

NAT Gateway provides outbound internet connectivity for subnets.

#### NAT Gateway Architecture

```mermaid
graph TB
    subgraph "Subnet (10.0.1.0/24)"
        VM1[VM 1<br/>No Public IP]
        VM2[VM 2<br/>No Public IP]
        VM3[VM 3<br/>No Public IP]
    end
    
    VM1 --> NAT[NAT Gateway]
    VM2 --> NAT
    VM3 --> NAT
    
    NAT --> PublicIP[Public IP<br/>20.1.2.3]
    PublicIP --> Internet[Internet]
```

#### NAT Gateway Benefits

- **Simplified Outbound**: No backend pools needed
- **High Performance**: Up to 50 Gbps
- **No SNAT Exhaustion**: 64,000 flows per public IP
- **Cost Effective**: Pay per hour and data processed
- **Zone Redundant**: Automatic high availability

---

## Application Delivery Services

### Azure CDN

Azure CDN delivers content to users with high bandwidth.

#### CDN Architecture

```mermaid
graph TB
    Origin[Origin Server<br/>Web App/Storage] --> CDN[Azure CDN]
    CDN --> Edge1[Edge Server 1<br/>US East]
    CDN --> Edge2[Edge Server 2<br/>Europe]
    CDN --> Edge3[Edge Server 3<br/>Asia]
    
    User1[User 1<br/>US] --> Edge1
    User2[User 2<br/>Europe] --> Edge2
    User3[User 3<br/>Asia] --> Edge3
```

#### CDN Features

- **Global Distribution**: Content cached at edge locations
- **Dynamic Acceleration**: Route optimization
- **Custom Domains**: Use your own domain
- **HTTPS**: SSL/TLS support
- **Compression**: Automatic compression
- **Rules Engine**: Customize content delivery

---

## Monitoring and Management

### Azure Network Watcher

Network Watcher provides tools to monitor, diagnose, and view metrics for your network.

#### Network Watcher Tools

```mermaid
graph TB
    NW[Network Watcher] --> Topology[Topology View]
    NW --> ConnectionMonitor[Connection Monitor]
    NW --> PacketCapture[Packet Capture]
    NW --> IPFlow[IP Flow Verify]
    NW --> NextHop[Next Hop]
    NW --> VPNTroubleshoot[VPN Troubleshoot]
    NW --> NSGFlow[NSG Flow Logs]
```

#### Key Features

1. **Topology**: Visualize network resources
2. **Connection Monitor**: Monitor connectivity
3. **Packet Capture**: Capture network packets
4. **IP Flow Verify**: Test if traffic is allowed
5. **Next Hop**: Determine routing path
6. **VPN Troubleshoot**: Diagnose VPN issues
7. **NSG Flow Logs**: Log network traffic

---

## Best Practices

### Network Design

1. **Hub-Spoke Architecture**: Centralize shared services
2. **Naming Conventions**: Consistent naming
3. **Address Space Planning**: Avoid overlaps
4. **Subnet Sizing**: Plan for growth
5. **NSG Rules**: Least privilege

### Security

1. **Defense in Depth**: Multiple security layers
2. **Zero Trust**: Verify all connections
3. **Network Segmentation**: Isolate workloads
4. **Monitoring**: Enable logging and monitoring
5. **Regular Audits**: Review security rules

### Performance

1. **Proximity**: Deploy close to users
2. **Caching**: Use CDN for static content
3. **Compression**: Enable compression
4. **Connection Pooling**: Reuse connections
5. **Load Balancing**: Distribute traffic

---

## Architecture Patterns

### Hub-Spoke Pattern

```mermaid
graph TB
    Hub[Hub VNet<br/>Shared Services] --> Spoke1[Spoke VNet 1<br/>Workload 1]
    Hub --> Spoke2[Spoke VNet 2<br/>Workload 2]
    Hub --> Spoke3[Spoke VNet 3<br/>Workload 3]
    
    Hub --> Firewall5[Azure Firewall]
    Hub --> VPN6[VPN Gateway]
    Hub --> Bastion2[Azure Bastion]
```

### Multi-Tier Application

```mermaid
graph TB
    Internet --> AppGW2[Application Gateway]
    AppGW2 --> WebTier[Web Tier<br/>Subnet]
    WebTier --> AppTier[App Tier<br/>Subnet]
    AppTier --> DBTier[DB Tier<br/>Subnet]
    
    WebTier --> NSG4[NSG: Web]
    AppTier --> NSG5[NSG: App]
    DBTier --> NSG6[NSG: DB]
```

---

## Conclusion

This guide provides a comprehensive overview of Azure networking services. Each service has specific use cases and should be selected based on your requirements.

For detailed implementation examples, see the module documentation and example configurations in this repository.

