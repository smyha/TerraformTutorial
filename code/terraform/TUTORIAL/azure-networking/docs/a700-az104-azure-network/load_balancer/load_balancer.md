# Azure Load Balancer

## Overview

Azure Load Balancer is a service you can use to distribute traffic across multiple virtual machines or other services. It allows you to scale the app to larger sizes than a single virtual machine can support, and ensures that users get service even when a virtual machine fails.

In your healthcare organization, you can expect large user demand. It's vitally important that each user can book an appointment, even during peak demand or when one or more virtual machines fail. By using multiple virtual servers for your front end with a load balancer to distribute traffic among them, you achieve a high capacity because all the virtual servers collaborate to satisfy requests. You also improve resilience because the load balancer can automatically reroute traffic when a virtual server fails.

Here, you learn how Load Balancer's features can help you create robust app architectures.

**Learn more:**
- [Azure Load Balancer Overview](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview)
- [Load Balancer Documentation](https://learn.microsoft.com/en-us/azure/load-balancer/)

## Load Balancing Services Categorization

Load balancing services can be classified in two ways: **Global vs Regional** and **HTTP(S) vs Non-HTTP(S)**.

### Global vs Regional

**Global load balancing services** distribute traffic across regional backend servers, clouds, or hybrid on-premises services. These services route end-user traffic to the nearest available backend server. They also react to changes in service reliability or performance. You can think of them as systems that load balance between stamps, endpoints, or application scale units hosted in different regions or geographic zones.

**Global Load Balancing Architecture:**
```mermaid
graph TB
    subgraph "Global Load Balancing"
        Users[End Users<br/>Worldwide] --> GlobalLB[Global Load Balancer<br/>Azure Front Door / Traffic Manager]
        
        GlobalLB --> Region1[Region 1<br/>East US]
        GlobalLB --> Region2[Region 2<br/>West Europe]
        GlobalLB --> Region3[Region 3<br/>Southeast Asia]
        
        Region1 --> Backend1[Backend Servers<br/>Region 1]
        Region2 --> Backend2[Backend Servers<br/>Region 2]
        Region3 --> Backend3[Backend Servers<br/>Region 3]
        
        GlobalLB --> Health[Health Monitoring<br/>Performance Monitoring]
        Health --> Region1
        Health --> Region2
        Health --> Region3
    end
    
    style GlobalLB fill:#90EE90
    style Region1 fill:#87CEEB
    style Region2 fill:#87CEEB
    style Region3 fill:#87CEEB
```

**Key Characteristics:**
- **Multi-Region Distribution**: Routes traffic across multiple Azure regions
- **Geographic Routing**: Routes users to nearest healthy region
- **Global Reach**: Supports worldwide distribution
- **Health-Based Routing**: Automatically routes to healthy endpoints
- **Performance Optimization**: Routes based on latency and performance

**Regional load balancing services**, in contrast, distribute traffic within virtual networks between virtual machines (VMs) or zonal and zone-redundant service endpoints within a region. You can think of them as systems that load balance between VMs, containers, or clusters within a region in a virtual network.

**Regional Load Balancing Architecture:**
```mermaid
graph TB
    subgraph "Regional Load Balancing"
        Clients[Clients<br/>Same Region] --> RegionalLB[Regional Load Balancer<br/>Application Gateway / Load Balancer]
        
        RegionalLB --> VNet[Virtual Network<br/>Single Region]
        
        VNet --> Subnet1[Subnet 1]
        VNet --> Subnet2[Subnet 2]
        VNet --> Subnet3[Subnet 3]
        
        Subnet1 --> VM1[VM 1<br/>Zone 1]
        Subnet2 --> VM2[VM 2<br/>Zone 2]
        Subnet3 --> VM3[VM 3<br/>Zone 3]
        
        RegionalLB --> Health[Health Probes<br/>Within Region]
        Health --> VM1
        Health --> VM2
        Health --> VM3
    end
    
    style RegionalLB fill:#FFE4B5
    style VNet fill:#87CEEB
```

**Key Characteristics:**
- **Single Region**: Operates within one Azure region
- **VNet Scope**: Distributes traffic within virtual networks
- **Zone Support**: Can distribute across availability zones within a region
- **Local Optimization**: Optimizes for regional performance
- **Lower Latency**: No cross-region routing overhead

**Global vs Regional Comparison:**
```mermaid
graph TB
    LB[Load Balancing Services] --> Global[Global Services]
    LB --> Regional[Regional Services]
    
    Global --> FrontDoor[Azure Front Door<br/>Global HTTP/HTTPS]
    Global --> TrafficManager[Traffic Manager<br/>Global Non-HTTP/S]
    
    Regional --> AppGateway[Application Gateway<br/>Regional HTTP/HTTPS]
    Regional --> AzureLB[Azure Load Balancer<br/>Regional Non-HTTP/S]
    
    Global --> Scope1[Multi-Region<br/>Worldwide]
    Regional --> Scope2[Single Region<br/>VNet Scope]
    
    style Global fill:#90EE90
    style Regional fill:#FFE4B5
```

### HTTP(S) vs Non-HTTP(S)

**HTTP(S) load balancing services** are Layer 7 load balancers that only accept HTTP(S) traffic. They are designed for web applications or other HTTP(S) endpoints. They include features such as SSL offloading, web application firewall, path-based load balancing, and session affinity.

**HTTP(S) Load Balancing Features:**
```mermaid
graph TB
    HTTPS[HTTP/S Load Balancing<br/>Layer 7] --> Features[Key Features]
    
    Features --> SSLOffload[SSL/TLS Offloading<br/>Terminate SSL at Load Balancer]
    Features --> WAF[Web Application Firewall<br/>Protection Against Attacks]
    Features --> PathBased[Path-Based Routing<br/>/api, /web, /admin]
    Features --> HostBased[Host-Based Routing<br/>api.example.com]
    Features --> SessionAffinity[Session Affinity<br/>Cookie-Based Sticky Sessions]
    Features --> URLRewrite[URL Rewriting<br/>Modify Request/Response]
    
    HTTPS --> Services[Azure Services]
    Services --> AppGateway[Application Gateway<br/>Regional]
    Services --> FrontDoor[Azure Front Door<br/>Global]
    
    style HTTPS fill:#90EE90
    style AppGateway fill:#87CEEB
    style FrontDoor fill:#87CEEB
```

**Key Characteristics:**
- **Layer 7**: Operates at application layer (HTTP/HTTPS)
- **Content-Aware**: Can inspect and route based on HTTP content
- **SSL Termination**: Can terminate SSL/TLS connections
- **Application Features**: WAF, URL rewriting, session affinity
- **Use Case**: Web applications, APIs, HTTP-based services

**Non-HTTP(S) load balancing services**, in contrast, can handle traffic that isn't HTTP(S) and are recommended for non-web workloads.

**Non-HTTP(S) Load Balancing Features:**
```mermaid
graph TB
    NonHTTPS[Non-HTTP/S Load Balancing<br/>Layer 4] --> Features[Key Features]
    
    Features --> TCP[TCP Load Balancing<br/>Any TCP Protocol]
    Features --> UDP[UDP Load Balancing<br/>Any UDP Protocol]
    Features --> PortBased[Port-Based Routing<br/>Port 22, 3389, 1433, etc.]
    Features --> HighPerf[High Performance<br/>Low Latency]
    Features --> Simple[Simple Configuration<br/>No Application Logic]
    
    NonHTTPS --> Services[Azure Services]
    Services --> AzureLB[Azure Load Balancer<br/>Regional]
    Services --> TrafficManager[Traffic Manager<br/>Global DNS-Based]
    
    style NonHTTPS fill:#FFE4B5
    style AzureLB fill:#87CEEB
    style TrafficManager fill:#87CEEB
```

**Key Characteristics:**
- **Layer 4**: Operates at transport layer (TCP/UDP)
- **Protocol Agnostic**: Works with any TCP/UDP protocol
- **High Performance**: Lower latency, higher throughput
- **Simple**: No application-layer processing
- **Use Case**: Database connections, RDP, SSH, custom protocols

**Important Note:**

> In this module, we focus on **non-HTTP(S) solutions**.

### Load Balancing Services Categorization Table

This table summarizes these categorizations for each Azure load balancing service:

| Service | Global or Regional | Recommended Traffic |
|---------|-------------------|---------------------|
| **Azure Front Door** | Global | HTTP(S) |
| **Traffic Manager** | Global | Non-HTTP(S) |
| **Application Gateway** | Regional | HTTP(S) |
| **Azure Load Balancer** | Regional | Non-HTTP(S) |

**Service Categorization Diagram:**
```mermaid
graph TB
    Services[Azure Load Balancing Services] --> Global[Global Services]
    Services --> Regional[Regional Services]
    
    Global --> GlobalHTTP[HTTP/S Services]
    Global --> GlobalNonHTTP[Non-HTTP/S Services]
    
    Regional --> RegionalHTTP[HTTP/S Services]
    Regional --> RegionalNonHTTP[Non-HTTP/S Services]
    
    GlobalHTTP --> FrontDoor[Azure Front Door<br/>Global HTTP/S]
    GlobalNonHTTP --> TrafficManager[Traffic Manager<br/>Global Non-HTTP/S]
    
    RegionalHTTP --> AppGateway[Application Gateway<br/>Regional HTTP/S]
    RegionalNonHTTP --> AzureLB[Azure Load Balancer<br/>Regional Non-HTTP/S]
    
    style FrontDoor fill:#90EE90
    style TrafficManager fill:#90EE90
    style AppGateway fill:#FFE4B5
    style AzureLB fill:#FFE4B5
```

### Choosing a Load Balancing Option for Azure

These are the key factors for deciding on a load balancing option:

#### 1. Traffic Type

**Question**: Is it for a web application? Is it a public or private application?

**Considerations:**
- **Web Application (HTTP/HTTPS)**: Use Application Gateway (regional) or Azure Front Door (global)
- **Non-Web Application**: Use Azure Load Balancer (regional) or Traffic Manager (global)
- **Public Application**: Requires public IP and internet accessibility
- **Private Application**: Uses private IP within VNet

**Traffic Type Decision Tree:**
```mermaid
graph TB
    Start[Application Type?] --> Web{Web Application<br/>HTTP/HTTPS?}
    
    Web -->|Yes| Public{Public or<br/>Private?}
    Web -->|No| NonWeb{Public or<br/>Private?}
    
    Public -->|Public| GlobalWeb{Global or<br/>Regional?}
    Public -->|Private| AppGateway[Application Gateway<br/>Regional HTTP/S]
    
    NonWeb -->|Public| GlobalNonWeb{Global or<br/>Regional?}
    NonWeb -->|Private| AzureLB[Azure Load Balancer<br/>Regional Non-HTTP/S]
    
    GlobalWeb -->|Global| FrontDoor[Azure Front Door<br/>Global HTTP/S]
    GlobalWeb -->|Regional| AppGateway
    
    GlobalNonWeb -->|Global| TrafficManager[Traffic Manager<br/>Global Non-HTTP/S]
    GlobalNonWeb -->|Regional| AzureLB
    
    style FrontDoor fill:#90EE90
    style AppGateway fill:#FFE4B5
    style TrafficManager fill:#90EE90
    style AzureLB fill:#FFE4B5
```

#### 2. Scope

**Question**: Do you need to load balance VMs and containers within a virtual network, or load balance across regions, or both?

**Considerations:**
- **Within VNet**: Use regional services (Application Gateway or Azure Load Balancer)
- **Across Regions**: Use global services (Azure Front Door or Traffic Manager)
- **Both**: Combine global and regional services

**Scope Decision:**
```mermaid
graph TB
    Scope{Load Balancing Scope?} --> VNet[Within Virtual Network<br/>Single Region]
    Scope --> Regions[Across Multiple Regions<br/>Global]
    Scope --> Both[Both VNet and Regions]
    
    VNet --> Regional[Regional Services]
    Regional --> HTTP1{HTTP/S?}
    HTTP1 -->|Yes| AppGateway[Application Gateway]
    HTTP1 -->|No| AzureLB[Azure Load Balancer]
    
    Regions --> Global[Global Services]
    Global --> HTTP2{HTTP/S?}
    HTTP2 -->|Yes| FrontDoor[Azure Front Door]
    HTTP2 -->|No| TrafficManager[Traffic Manager]
    
    Both --> Combined[Combined Architecture]
    Combined --> GlobalLB[Global Load Balancer<br/>Front Door or Traffic Manager]
    Combined --> RegionalLB[Regional Load Balancer<br/>App Gateway or Azure LB]
    GlobalLB --> RegionalLB
    
    style GlobalLB fill:#90EE90
    style RegionalLB fill:#FFE4B5
```

#### 3. Availability

**Question**: What is the Service Level Agreement (SLA) of the service?

**SLA Comparison:**

| Service | SLA | Availability Features |
|---------|-----|----------------------|
| **Azure Front Door** | 99.99% | Global distribution, automatic failover |
| **Traffic Manager** | 99.99% | DNS-based failover, health monitoring |
| **Application Gateway** | 99.95% | Zone redundancy, health probes |
| **Azure Load Balancer** | 99.99% (Standard) | Zone redundancy, availability zones |

**SLA Architecture:**
```mermaid
graph TB
    SLA[Service Level Agreement] --> High[99.99% SLA]
    SLA --> Standard[99.95% SLA]
    
    High --> FrontDoor[Azure Front Door<br/>99.99%]
    High --> TrafficManager[Traffic Manager<br/>99.99%]
    High --> AzureLB[Azure Load Balancer<br/>99.99% Standard SKU]
    
    Standard --> AppGateway[Application Gateway<br/>99.95%]
    Standard --> BasicLB[Azure Load Balancer<br/>99.95% Basic SKU]
    
    High --> Features1[Zone Redundancy<br/>Automatic Failover<br/>Health Monitoring]
    Standard --> Features2[Availability Sets<br/>Health Probes]
    
    style High fill:#90EE90
    style Standard fill:#FFE4B5
```

#### 4. Cost

**Question**: In addition to the actual service cost, consider the operational cost to manage and maintain a solution integrated into that service.

**Cost Considerations:**
- **Service Cost**: Base pricing for the load balancing service
- **Data Transfer Costs**: Cross-region data transfer costs (for global services)
- **Operational Costs**: Management and maintenance overhead
- **Resource Costs**: Backend resources (VMs, containers)

**Cost Comparison:**
```mermaid
graph TB
    Cost[Cost Factors] --> ServiceCost[Service Cost]
    Cost --> DataTransfer[Data Transfer Cost]
    Cost --> Operational[Operational Cost]
    Cost --> Resources[Resource Cost]
    
    ServiceCost --> GlobalCost[Global Services<br/>Higher Base Cost]
    ServiceCost --> RegionalCost[Regional Services<br/>Lower Base Cost]
    
    DataTransfer --> CrossRegion[Cross-Region Transfer<br/>Additional Cost]
    DataTransfer --> SameRegion[Same Region Transfer<br/>Lower Cost]
    
    Operational --> Management[Management Overhead<br/>Monitoring, Maintenance]
    
    Resources --> Backend[Backend Resources<br/>VMs, Containers]
    
    style GlobalCost fill:#FFB6C1
    style RegionalCost fill:#90EE90
```

**Learn more:**
- [Load Balancing Pricing](https://azure.microsoft.com/pricing/details/load-balancer/)
- [Application Gateway Pricing](https://azure.microsoft.com/pricing/details/application-gateway/)
- [Front Door Pricing](https://azure.microsoft.com/pricing/details/frontdoor/)
- [Traffic Manager Pricing](https://azure.microsoft.com/pricing/details/traffic-manager/)

#### 5. Features and Limitations

**Question**: What features and advantages does each service provide and what are their limitations?

**Feature Comparison:**

| Feature | Azure Front Door | Traffic Manager | Application Gateway | Azure Load Balancer |
|---------|-----------------|-----------------|---------------------|---------------------|
| **Layer** | Layer 7 (HTTP/HTTPS) | Layer 4 (DNS) | Layer 7 (HTTP/HTTPS) | Layer 4 (TCP/UDP) |
| **Scope** | Global | Global | Regional | Regional |
| **SSL Offloading** | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| **WAF** | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| **Path-Based Routing** | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| **Session Affinity** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes (Source IP) |
| **Health Probes** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Zone Redundancy** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (Standard) |

**Learn more:**
- [Load Balancer Limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#load-balancer)
- [Application Gateway Limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#application-gateway)
- [Front Door Limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-front-door-service)

### Load Balancing Decision Tree

The following decision tree helps you choose the right Azure load balancing service based on your requirements:

![Load Balancing Decision Tree](../img/load-balancing-decision-tree-3f132096.png)

**Decision Tree Overview:**

The decision tree guides you through selecting the appropriate Azure networking service based on:

1. **Application Type**: Web application (HTTP/HTTPS) or non-web application
2. **Accessibility**: Internet-accessible or private application
3. **Geographic Scope**: Global/multiple regions or single region
4. **Performance Requirements**: Performance acceleration needs
5. **Application Layer Processing**: SSL offloading or per-request processing
6. **Hosting Model**: PaaS (App Service, Functions), IaaS (VMs), or AKS

**Key Decision Points:**

- **Web Application (HTTP/HTTPS)**:
  - If **Internet-accessible** and **Global**: Azure Front Door
  - If **Internet-accessible** and **Regional**: Application Gateway
  - If **Private**: Application Gateway
  - If **Global** with **SSL offloading**: Azure Front Door + Application Gateway
  - If **Global** with **PaaS hosting**: Azure Front Door
  - If **Global** with **AKS**: Azure Front Door + Application Gateway Ingress Controller
  - If **Global** with **IaaS (VMs)**: Azure Front Door + Azure Load Balancer

- **Non-Web Application**:
  - If **Internet-accessible** and **Global**: Traffic Manager + Azure Load Balancer
  - If **Internet-accessible** and **Regional**: Azure Load Balancer
  - If **Private**: Azure Load Balancer

**Decision Tree Mermaid Representation:**
```mermaid
graph TB
    Start[Start] --> AppType{Web Application?<br/>HTTP/HTTPS}
    
    AppType -->|No| NonWeb{Internet<br/>Accessible?}
    AppType -->|Yes| Web{Internet<br/>Accessible?}
    
    NonWeb -->|No| AzureLB1[Azure Load Balancer<br/>Internal]
    NonWeb -->|Yes| Global1{Global/<br/>Multiple Regions?}
    
    Global1 -->|No| AzureLB2[Azure Load Balancer<br/>External]
    Global1 -->|Yes| TrafficManager[Traffic Manager +<br/>Azure Load Balancer]
    
    Web -->|No| AppGateway1[Application Gateway<br/>Internal]
    Web -->|Yes| Global2{Global/<br/>Multiple Regions?}
    
    Global2 -->|No| Perf{Performance<br/>Acceleration?}
    Global2 -->|Yes| SSL{SSL Offloading or<br/>App Layer Processing?}
    
    Perf -->|No| AppGateway2[Application Gateway]
    Perf -->|Yes| SSL
    
    SSL -->|Yes| FrontDoorAG[Azure Front Door +<br/>Application Gateway]
    SSL -->|No| Hosting{Hosting Model?}
    
    Hosting --> PaaS[PaaS<br/>App Service/Functions] --> FrontDoor1[Azure Front Door]
    Hosting --> AKS[AKS] --> FrontDoorAG2[Azure Front Door +<br/>Application Gateway Ingress]
    Hosting --> IaaS[IaaS<br/>VMs] --> FrontDoorLB[Azure Front Door +<br/>Azure Load Balancer]
    
    style FrontDoor1 fill:#90EE90
    style FrontDoorAG fill:#90EE90
    style FrontDoorAG2 fill:#90EE90
    style FrontDoorLB fill:#90EE90
    style AppGateway1 fill:#FFE4B5
    style AppGateway2 fill:#FFE4B5
    style TrafficManager fill:#90EE90
    style AzureLB1 fill:#FFE4B5
    style AzureLB2 fill:#FFE4B5
```

## Distribute traffic with Azure Load Balancer

Azure Load Balancer is a service you can use to distribute traffic across multiple virtual machines. Use Load Balancer to scale applications and create high availability for your virtual machines and services. Load balancers use a hash-based distribution algorithm. By default, a five-tuple hash is used to map traffic to available servers. The hash is made from the following elements:

- **Source IP**: The IP address of the requesting client.
- **Source port**: The port of the requesting client.
- **Destination IP**: The destination IP of the request.
- **Destination port**: The destination port of the request.
- **Protocol type**: The specified protocol type. Transmission Control Protocol (TCP) or User Datagram Protocol (UDP).

**Load Balancer Distribution Algorithm:**
```mermaid
graph TB
    Clients[Client Requests] --> LB[Azure Load Balancer]
    LB --> Hash[Five-Tuple Hash Algorithm]
    
    Hash --> Extract[Extract Five-Tuple:<br/>Source IP, Source Port,<br/>Dest IP, Dest Port, Protocol]
    Extract --> Map[Map to Available Server]
    
    Map --> VM1[VM 1]
    Map --> VM2[VM 2]
    Map --> VM3[VM 3]
    Map --> VM4[VM 4]
    
    VM1 --> Response1[Response]
    VM2 --> Response2[Response]
    VM3 --> Response3[Response]
    VM4 --> Response4[Response]
    
    Response1 --> Clients
    Response2 --> Clients
    Response3 --> Clients
    Response4 --> Clients
```

**Load Balancer Overview:**
```mermaid
graph TB
    Internet[Internet Traffic] --> LB[Azure Load Balancer]
    LB --> BackendPool[Backend Pool]
    
    BackendPool --> VM1[VM 1<br/>Availability Zone 1]
    BackendPool --> VM2[VM 2<br/>Availability Zone 2]
    BackendPool --> VM3[VM 3<br/>Availability Zone 3]
    
    LB --> HealthProbe[Health Probes]
    HealthProbe --> VM1
    HealthProbe --> VM2
    HealthProbe --> VM3
    
    VM1 -->|Healthy| LB
    VM2 -->|Healthy| LB
    VM3 -->|Unhealthy| LB
```

**Key Features:**
- Load Balancer supports inbound and outbound scenarios
- Provides low latency and high throughput
- Scales up to millions of flows for TCP and UDP applications
- Load balancers aren't physical instances - they're objects that express how Azure configures its infrastructure

**Learn more:**
- [Load Balancer Distribution Modes](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-distribution-mode)
- [Load Balancer Components](https://learn.microsoft.com/en-us/azure/load-balancer/components)

## Availability Sets and Availability Zones

With Load Balancer, you can use availability sets and availability zones to ensure that virtual machines are always available:

| Configuration | Service level agreement (SLA) | Information |
|---------------|-------------------------------|-------------|
| **Availability set** | 99.95% | Protection from hardware failures within datacenters |
| **Availability zone** | 99.99% | Protection from entire datacenter failure |

### Availability Sets

An availability set is a logical grouping used to isolate virtual machine resources from each other when they're deployed. Azure ensures that the virtual machines you put in an availability set run across multiple physical servers, compute racks, storage units, and network switches. If there's a hardware or software failure, only a subset of your virtual machines is affected. Your overall solution stays operational. Availability sets are essential for building reliable cloud solutions.

**Availability Set Architecture:**
```mermaid
graph TB
    LB[Load Balancer] --> AS[Availability Set]
    
    AS --> FD1[Fault Domain 1]
    AS --> FD2[Fault Domain 2]
    AS --> FD3[Fault Domain 3]
    
    FD1 --> VM1[VM 1<br/>Physical Server 1]
    FD2 --> VM2[VM 2<br/>Physical Server 2]
    FD3 --> VM3[VM 3<br/>Physical Server 3]
    
    FD1 --> UD1[Update Domain 1]
    FD2 --> UD2[Update Domain 2]
    FD3 --> UD3[Update Domain 3]
    
    style FD1 fill:#FFE4B5
    style FD2 fill:#FFE4B5
    style FD3 fill:#FFE4B5
```

**Key Characteristics:**
- **Fault Domains**: VMs are distributed across different physical servers, racks, and network switches
- **Update Domains**: VMs are grouped to allow planned maintenance without affecting all VMs
- **High Availability**: Protects against hardware failures within a datacenter
- **SLA**: 99.95% uptime guarantee

**Learn more:**
- [Availability Sets Overview](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)
- [Manage Availability Sets](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)

### Availability Zones

An availability zone offers groups of one or more datacenters that have independent power, cooling, and networking. The virtual machines in an availability zone are placed in different physical locations within the same region. Use this architecture when you want to ensure that you can continue to serve users when an entire datacenter fails.

**Availability Zone Architecture:**
```mermaid
graph TB
    LB[Load Balancer<br/>Zone-Redundant] --> AZ1[Availability Zone 1<br/>Datacenter 1]
    LB --> AZ2[Availability Zone 2<br/>Datacenter 2]
    LB --> AZ3[Availability Zone 3<br/>Datacenter 3]
    
    AZ1 --> VM1[VM 1<br/>Independent Power/Cooling/Networking]
    AZ2 --> VM2[VM 2<br/>Independent Power/Cooling/Networking]
    AZ3 --> VM3[VM 3<br/>Independent Power/Cooling/Networking]
    
    AZ1 -.->|Datacenter Failure| AZ2
    AZ2 -.->|Datacenter Failure| AZ3
    AZ3 -.->|Datacenter Failure| AZ1
    
    style AZ1 fill:#90EE90
    style AZ2 fill:#90EE90
    style AZ3 fill:#90EE90
```

**Key Characteristics:**
- **Independent Infrastructure**: Each zone has separate power, cooling, and networking
- **Physical Separation**: VMs are placed in different physical datacenters
- **Higher SLA**: 99.99% uptime guarantee
- **Regional Scope**: Zones are within the same Azure region

**Important Considerations:**
- Availability zones don't support all virtual machine sizes
- Not available in all Azure regions
- Check that they're supported in your region before using them in your architecture

**Learn more:**
- [Availability Zones Overview](https://learn.microsoft.com/en-us/azure/availability-zones/az-overview)
- [Regions with Availability Zones](https://learn.microsoft.com/en-us/azure/availability-zones/az-region)

## Select the right Load Balancer product

Two products are available when you create a load balancer in Azure: basic load balancers and standard load balancers.

### Basic Load Balancers

Basic load balancers allow:

- Port forwarding
- Automatic reconfiguration
- Health probes
- Outbound connections through source network address translation (SNAT)
- Diagnostics through Azure Log Analytics for public-facing load balancers

**Limitations:**
- You can only use basic load balancers with a single availability set or scale set
- No availability zone support
- Limited features compared to Standard Load Balancer

**Use Cases:**
- Development and testing environments
- Simple applications with basic requirements
- Cost-sensitive scenarios

**Learn more:**
- [Basic Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview#skus)

### Standard Load Balancers

Standard load balancers support all of the basic load balancer features. They also allow:

- HTTPS health probes
- Availability zones
- Diagnostics through Azure Monitor, for multidimensional metrics
- High availability (HA) ports
- Outbound rules
- A guaranteed SLA (99.99% for two or more virtual machines)

**Key Advantages:**
- **Higher SLA**: 99.99% uptime guarantee (vs 99.95% for Basic)
- **Advanced Features**: HA ports, outbound rules, zone redundancy
- **Better Monitoring**: Multidimensional metrics through Azure Monitor
- **Production Ready**: Recommended for production workloads

**Use Cases:**
- Production applications requiring high availability
- Applications needing zone redundancy
- Enterprise workloads with strict SLA requirements

**Learn more:**
- [Standard Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-overview)
- [Load Balancer SKU Comparison](https://learn.microsoft.com/en-us/azure/load-balancer/skus)

**Load Balancer SKU Comparison:**
```mermaid
graph TB
    LB[Load Balancer] --> Basic[Basic SKU]
    LB --> Standard[Standard SKU]
    
    Basic --> Features1[Port Forwarding<br/>Health Probes<br/>SNAT<br/>Log Analytics]
    Basic --> Limits1[Single Availability Set<br/>No Zones<br/>99.95% SLA]
    
    Standard --> Features2[All Basic Features +<br/>HTTPS Probes<br/>Availability Zones<br/>HA Ports<br/>Outbound Rules<br/>Azure Monitor]
    Standard --> Limits2[Multiple Availability Sets<br/>Zone Support<br/>99.99% SLA]
```

## Internal and external load balancers

### External Load Balancer

An external load balancer operates by distributing client traffic across multiple virtual machines. An external load balancer permits traffic from the internet. The traffic might come from browsers, mobile apps, or other sources. In a healthcare organization, the balancer distributes the load of all the browsers that run the client healthcare application.

**External Load Balancer Architecture:**
```mermaid
graph TB
    Internet[Internet Users<br/>Browsers, Mobile Apps] --> ELB[External Load Balancer<br/>Public IP Address]
    ELB --> BackendPool[Backend Pool]
    
    BackendPool --> WebVM1[Web Server VM 1]
    BackendPool --> WebVM2[Web Server VM 2]
    BackendPool --> WebVM3[Web Server VM 3]
    
    WebVM1 --> Response1[Response]
    WebVM2 --> Response2[Response]
    WebVM3 --> Response3[Response]
    
    Response1 --> Internet
    Response2 --> Internet
    Response3 --> Internet
```

**Key Characteristics:**
- **Public IP Address**: Has a public-facing IP address
- **Internet Traffic**: Accepts traffic from the internet
- **Use Case**: Front-end web servers, public-facing applications
- **Example**: Healthcare application accessible from browsers and mobile apps

**Learn more:**
- [Public Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview#public-load-balancer)

### Internal Load Balancer

In addition to balancing requests from users to front-end servers, you can use Azure Load Balancer to distribute traffic from front-end servers evenly among back-end servers.

In your healthcare organization, front-end servers call business logic services hosted on a middle tier. You want to ensure that the middle tier is as scalable and resilient as the front end. You want to use a load balancer to distribute requests from the front-end servers evenly among the middle-tier servers. This way, you can scale out the middle-tier servers to achieve the highest capacity possible. You also ensure that the middle tier is resilient to failure. When a server fails, the load balancer automatically reroutes traffic to another server.

An internal load balancer distributes a load from internal Azure resources to other Azure resources. For example, if you have front-end web servers that need to call the business logic hosted on multiple middle-tier servers, you can distribute that load evenly by using an internal load balancer. No traffic is allowed from internet sources. In a healthcare organization, a load balancer distributes a load across the internal application tier.

**Internal Load Balancer Architecture:**
```mermaid
graph TB
    Frontend[Front-End Web Servers<br/>10.0.1.0/24] --> ILB[Internal Load Balancer<br/>Private IP: 10.0.2.10]
    ILB --> BackendPool[Backend Pool]
    
    BackendPool --> AppVM1[Application Server VM 1<br/>10.0.2.11]
    BackendPool --> AppVM2[Application Server VM 2<br/>10.0.2.12]
    BackendPool --> AppVM3[Application Server VM 3<br/>10.0.2.13]
    
    AppVM1 --> Response1[Response]
    AppVM2 --> Response2[Response]
    AppVM3 --> Response3[Response]
    
    Response1 --> Frontend
    Response2 --> Frontend
    Response3 --> Frontend
    
    Internet[Internet] -.->|No Access| ILB
```

**Key Characteristics:**
- **Private IP Address**: Uses a private IP address within the VNet
- **Internal Traffic Only**: No internet access allowed
- **Use Case**: Multi-tier applications, internal services
- **Example**: Application tier load balancing in healthcare organization

#### Configure an Internal Load Balancer

In the healthcare-portal scenario, a web tier handles requests from users. The web tier connects to databases to retrieve data for users. The database tier is also deployed on two virtual machines. To allow the front-end web portal to continue to serve client requests if a database server fails, you can set up an internal load balancer to distribute traffic to the database servers.

**Healthcare Portal Internal Load Balancer Architecture:**
```mermaid
graph TB
    Users[Internet Users] --> WebTier[Web Tier<br/>Front-End Servers]
    WebTier --> ILB[Internal Load Balancer<br/>Private IP: 10.0.2.10]
    ILB --> DatabasePool[Database Backend Pool]
    
    DatabasePool --> DBVM1[Database Server VM 1<br/>10.0.2.11]
    DatabasePool --> DBVM2[Database Server VM 2<br/>10.0.2.12]
    
    DBVM1 --> Response1[Database Response]
    DBVM2 --> Response2[Database Response]
    
    Response1 --> WebTier
    Response2 --> WebTier
    WebTier --> Users
    
    Internet[Internet] -.->|No Direct Access| ILB
    Internet -.->|No Direct Access| DatabasePool
```

You can configure an internal load balancer in almost the same way as an external load balancer, but with these differences:

**Configuration Differences:**

1. **Type Selection**: When you create the load balancer, select **Internal** for the Type value. When you select this setting, the load balancer's front-end IP address isn't exposed to the internet.

2. **IP Address**: Assign a **private IP address** instead of a public IP address for the load balancer's front end.

3. **Network Placement**: Place the load balancer in the **protected virtual network** that contains the virtual machines you want to handle the requests.

**Internal Load Balancer Configuration:**
```mermaid
graph TB
    subgraph "Virtual Network: 10.0.0.0/16"
        subgraph "Subnet 1: Web Tier (10.0.1.0/24)"
            WebVM1[Web Server VM 1]
            WebVM2[Web Server VM 2]
        end
        
        subgraph "Subnet 2: Database Tier (10.0.2.0/24)"
            ILB[Internal Load Balancer<br/>Private IP: 10.0.2.10]
            DBVM1[Database VM 1<br/>10.0.2.11]
            DBVM2[Database VM 2<br/>10.0.2.12]
        end
    end
    
    WebVM1 --> ILB
    WebVM2 --> ILB
    ILB --> DBVM1
    ILB --> DBVM2
```

The internal load balancer should be visible only to the web tier. All the virtual machines that host the databases are in one subnet. You can use an internal load balancer to distribute traffic to those virtual machines.

**Key Configuration Requirements:**
- **Virtual Network**: Virtual machines must be in the same virtual network
- **Private IP**: Load balancer uses a private IP address (not public)
- **Subnet Placement**: Load balancer and backend VMs can be in the same or different subnets within the VNet
- **No Internet Access**: Load balancer is not accessible from the internet

#### Choose the Distribution Mode

In the healthcare portal, the application tier is stateless, so you don't need to use source IP affinity. You can use the default distribution mode of a **five-tuple hash**. This mode offers the greatest scalability and resilience. The load balancer routes traffic to any healthy server.

**Distribution Mode Options:**

1. **Five-Tuple Hash (Default)**: 
   - Uses source IP, source port, destination IP, destination port, and protocol
   - Best for stateless applications
   - Maximum scalability and resilience
   - Traffic can be routed to any healthy server

2. **Source IP Affinity (Session Affinity)**:
   - Routes traffic from the same source IP to the same backend server
   - Useful for stateful applications
   - May reduce scalability

**Distribution Mode Comparison:**
```mermaid
graph TB
    Request[Client Request] --> Mode{Distribution Mode}
    
    Mode -->|Five-Tuple Hash| Hash[Hash Algorithm<br/>Source IP + Port<br/>Dest IP + Port<br/>Protocol]
    Mode -->|Source IP Affinity| Affinity[Session Affinity<br/>Same Source IP<br/>Same Backend Server]
    
    Hash --> AnyServer[Any Healthy Server]
    Affinity --> SameServer[Same Backend Server]
    
    AnyServer --> Stateless[Stateless Apps<br/>Maximum Scalability]
    SameServer --> Stateful[Stateful Apps<br/>Session Persistence]
```

**Best Practice**: For stateless applications like the healthcare portal application tier, use the default five-tuple hash distribution mode for maximum scalability and resilience.

**Learn more:**
- [Internal Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview#internal-load-balancer)
- [Load Balancer Distribution Modes](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-distribution-mode)

**Load Balancer Types Comparison:**
```mermaid
graph TB
    LB[Load Balancer Types] --> External[External Load Balancer]
    LB --> Internal[Internal Load Balancer]
    
    External --> PublicIP[Public IP Address]
    External --> Internet[Internet Traffic]
    External --> UseCase1[Public-Facing Apps<br/>Web Servers]
    
    Internal --> PrivateIP[Private IP Address]
    Internal --> VNetOnly[VNet Traffic Only]
    Internal --> UseCase2[Multi-Tier Apps<br/>Internal Services]
```

## Load Balancer Components

**Complete Load Balancer Architecture:**
```mermaid
graph TB
    subgraph "Load Balancer Components"
        Frontend[Frontend IP Configuration<br/>Public or Private IP]
        BackendPool[Backend Pool<br/>VMs or Instances]
        HealthProbe[Health Probes<br/>Monitor Backend Health]
        LoadBalancingRules[Load Balancing Rules<br/>Distribution Logic]
    end
    
    Clients[Client Requests] --> Frontend
    Frontend --> LoadBalancingRules
    LoadBalancingRules --> BackendPool
    HealthProbe --> BackendPool
    BackendPool --> VMs[Virtual Machines]
    
    VMs -->|Health Status| HealthProbe
    HealthProbe -->|Remove Unhealthy| LoadBalancingRules
```

**Key Components:**
1. **Frontend IP Configuration**: Public or private IP address that receives traffic
2. **Backend Pool**: Collection of VMs or instances that serve requests
3. **Health Probes**: Monitor the health of backend instances
4. **Load Balancing Rules**: Define how traffic is distributed

**Learn more:**
- [Load Balancer Components](https://learn.microsoft.com/en-us/azure/load-balancer/components)
- [Configure Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-portal)

## Best Practices

### 1. Use Standard Load Balancer for Production
- Standard Load Balancer provides better SLA (99.99%)
- Supports availability zones for higher resilience
- Advanced monitoring and diagnostics

### 2. Deploy Across Availability Zones
- Use availability zones for maximum resilience
- Ensure VMs are distributed across zones
- Configure zone-redundant load balancer

### 3. Configure Health Probes
- Set appropriate probe intervals
- Configure healthy/unhealthy thresholds
- Monitor probe results in Azure Monitor

### 4. Use Availability Sets as Fallback
- If availability zones aren't available, use availability sets
- Distribute VMs across fault and update domains
- Ensures 99.95% SLA

### 5. Monitor and Alert
- Set up Azure Monitor alerts for load balancer metrics
- Monitor backend pool health
- Track connection counts and throughput

## Check Your Knowledge

### Question 1: Internal Load Balancer Configuration

**Which configuration is required to configure an internal load balancer?**

- ✅ **Correct**: Virtual machines must be in the same virtual network.

**Why:**
- Internal load balancers distribute traffic within a virtual network
- All backend VMs must be in the same VNet as the load balancer
- The load balancer uses a private IP address within the VNet
- This ensures traffic stays internal and is not exposed to the internet

- ❌ **Not correct**: Virtual machines must be publicly accessible.
  - Internal load balancers are specifically designed for private, internal traffic
  - Backend VMs do not need public IP addresses
  - The load balancer itself uses a private IP address

- ❌ **Not correct**: Virtual machines must be in an availability set.
  - While availability sets provide high availability, they are not required for internal load balancers
  - VMs can be in availability sets, availability zones, or neither
  - The key requirement is that VMs are in the same virtual network

### Question 2: External Load Balancer Characteristics

**Which one of the following statements about external load balancers is correct?**

- ✅ **Correct**: They have a public IP address.

**Why:**
- External load balancers are designed to accept traffic from the internet
- They require a public IP address to be accessible from the internet
- This allows browsers, mobile apps, and other internet clients to reach the load balancer
- The public IP address is the entry point for external traffic

- ❌ **Not correct**: They have a private, front-facing IP address.
  - External load balancers use public IP addresses, not private
  - Private IP addresses are used by internal load balancers
  - The term "front-facing" refers to the frontend IP configuration, which must be public for external load balancers

- ❌ **Not correct**: They don't have a listener IP address.
  - External load balancers do have a listener IP address (the frontend IP)
  - This is the public IP address that receives incoming traffic
  - The listener IP is essential for routing traffic to backend servers

## Summary

Azure Load Balancer provides:
- **Traffic Distribution**: Hash-based algorithm using five-tuple
- **High Availability**: Works with availability sets (99.95% SLA) and availability zones (99.99% SLA)
- **Scalability**: Scale applications beyond single VM capacity
- **Resilience**: Automatic traffic rerouting when VMs fail
- **Flexibility**: External (internet-facing) or internal (VNet-only) configurations
- **Product Options**: Basic (dev/test) or Standard (production) SKUs
- **Distribution Modes**: Five-tuple hash (default) for stateless apps, or source IP affinity for stateful apps

**Key Differences: External vs Internal Load Balancer**

| Feature | External Load Balancer | Internal Load Balancer |
|---------|------------------------|------------------------|
| **IP Address** | Public IP address | Private IP address |
| **Traffic Source** | Internet traffic | Internal VNet traffic only |
| **Accessibility** | Accessible from internet | Only accessible within VNet |
| **Use Case** | Public-facing applications | Multi-tier internal applications |
| **Configuration** | Type: Public | Type: Internal |

**Additional Resources:**
- [Load Balancer Quickstart](https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-portal)
- [Load Balancer Tutorials](https://learn.microsoft.com/en-us/azure/load-balancer/tutorial-load-balancer-standard-public-zone-redundant-portal)
- [Load Balancer Best Practices](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-overview)
- [Load Balancer FAQ](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-faqs)

