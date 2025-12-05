# Azure Networking Architectures and Communication Flows

This document provides comprehensive Mermaid diagrams showing complete architectures and communication flows for Azure networking services.

## Table of Contents

1. [Core Networking Architecture](#core-networking-architecture)
2. [Multi-Tier Application Architecture](#multi-tier-application-architecture)
3. [Hybrid Cloud Architecture](#hybrid-cloud-architecture)
4. [Global Distribution Architecture](#global-distribution-architecture)
5. [Hub-Spoke Architecture](#hub-spoke-architecture)
6. [DNS Resolution Flows](#dns-resolution-flows)
7. [Security Architecture](#security-architecture)
8. [Load Balancing Flows](#load-balancing-flows)

---

## Core Networking Architecture

### Complete Virtual Network with DNS

This diagram shows a complete Virtual Network architecture with DNS resolution, subnets, NSGs, and route tables.

```mermaid
graph TB
    subgraph "Internet"
        User[User/Client]
        InternetDNS[Internet DNS<br/>8.8.8.8]
    end
    
    subgraph "Azure Virtual Network (10.0.0.0/16)"
        subgraph "DNS Resolution"
            AzureDNS[Azure DNS<br/>168.63.129.16]
            PrivateDNS[Private DNS Zone<br/>internal.company.local]
        end
        
        subgraph "Web Subnet (10.0.1.0/24)"
            WebVM1[Web VM 1<br/>10.0.1.10<br/>web-vm-01]
            WebVM2[Web VM 2<br/>10.0.1.11<br/>web-vm-02]
            WebNSG[NSG: Web<br/>Allow HTTP/HTTPS]
        end
        
        subgraph "App Subnet (10.0.2.0/24)"
            AppVM1[App VM 1<br/>10.0.2.10<br/>app-vm-01]
            AppVM2[App VM 2<br/>10.0.2.11<br/>app-vm-02]
            AppNSG[NSG: App<br/>Allow from Web]
        end
        
        subgraph "DB Subnet (10.0.3.0/24)"
            DBVM[DB VM<br/>10.0.3.10<br/>db-vm-01]
            DBNSG[NSG: DB<br/>Allow from App]
        end
        
        RouteTable[Route Table<br/>Default Routes]
    end
    
    User -->|1. DNS Query: web-vm-01.internal| AzureDNS
    AzureDNS -->|2. Resolve to 10.0.1.10| PrivateDNS
    PrivateDNS -->|3. Return IP| User
    User -->|4. HTTP Request| WebVM1
    WebVM1 -->|5. DNS Query: db-vm-01.internal| AzureDNS
    AzureDNS -->|6. Resolve to 10.0.3.10| PrivateDNS
    WebVM1 -->|7. Connect to DB| DBVM
    
    WebNSG -.->|Filter Traffic| WebVM1
    WebNSG -.->|Filter Traffic| WebVM2
    AppNSG -.->|Filter Traffic| AppVM1
    AppNSG -.->|Filter Traffic| AppVM2
    DBNSG -.->|Filter Traffic| DBVM
    
    RouteTable -.->|Route Traffic| WebVM1
    RouteTable -.->|Route Traffic| AppVM1
    RouteTable -.->|Route Traffic| DBVM
```

**Key Points:**
- DNS resolution happens at multiple levels (Azure DNS, Private DNS zones)
- NSGs filter traffic at the subnet level
- Route tables control traffic routing
- Resources communicate using DNS names, not IP addresses

---

## Multi-Tier Application Architecture

### Complete Multi-Tier Application with Load Balancer and Application Gateway

This diagram shows a production-ready multi-tier application with load balancing, DNS, and security.

```mermaid
sequenceDiagram
    participant User
    participant DNS as Azure DNS
    participant AppGW as Application Gateway<br/>(Layer 7)
    participant LB as Load Balancer<br/>(Layer 4)
    participant WebVM1 as Web VM 1
    participant WebVM2 as Web VM 2
    participant AppVM1 as App VM 1
    participant AppVM2 as App VM 2
    participant DB as Database
    
    User->>DNS: 1. DNS Query: www.example.com
    DNS->>User: 2. Return IP: 20.1.2.3 (AppGW)
    
    User->>AppGW: 3. HTTPS Request: www.example.com
    AppGW->>AppGW: 4. SSL Termination
    AppGW->>AppGW: 5. Host-based Routing
    AppGW->>AppGW: 6. WAF Inspection
    
    AppGW->>LB: 7. Forward to Load Balancer<br/>(10.0.1.100)
    LB->>LB: 8. Health Probe Check
    LB->>WebVM1: 9. Route to Web VM 1<br/>(10.0.1.10)
    
    WebVM1->>WebVM1: 10. DNS Query: api.internal
    WebVM1->>AppVM1: 11. API Request<br/>(10.0.2.10)
    
    AppVM1->>AppVM1: 12. DNS Query: db.internal
    AppVM1->>DB: 13. Database Query<br/>(10.0.3.10)
    
    DB->>AppVM1: 14. Return Data
    AppVM1->>WebVM1: 15. Return API Response
    WebVM1->>LB: 16. Return HTTP Response
    LB->>AppGW: 17. Return Response
    AppGW->>User: 18. Return HTTPS Response
```

**Architecture Diagram:**

```mermaid
graph TB
    subgraph "Internet"
        Users[Users Worldwide]
    end
    
    subgraph "DNS Layer"
        PublicDNS[Azure DNS<br/>example.com]
        PrivateDNS[Private DNS Zone<br/>internal]
    end
    
    subgraph "Application Gateway (20.1.2.3)"
        AppGW[Application Gateway<br/>WAF Enabled]
        AppGWListener[HTTPS Listener<br/>www.example.com]
        AppGWRule[Routing Rule<br/>Host-based]
    end
    
    subgraph "VNet: Production (10.0.0.0/16)"
        subgraph "Web Subnet (10.0.1.0/24)"
            LB[Load Balancer<br/>10.0.1.100]
            WebPool[Backend Pool]
            WebVM1[Web VM 1<br/>10.0.1.10]
            WebVM2[Web VM 2<br/>10.0.1.11]
        end
        
        subgraph "App Subnet (10.0.2.0/24)"
            AppVM1[App VM 1<br/>10.0.2.10<br/>api.internal]
            AppVM2[App VM 2<br/>10.0.2.11<br/>api.internal]
        end
        
        subgraph "DB Subnet (10.0.3.0/24)"
            DB[Database<br/>10.0.3.10<br/>db.internal]
        end
    end
    
    Users -->|1. DNS Query| PublicDNS
    PublicDNS -->|2. CNAME to AppGW| Users
    Users -->|3. HTTPS Request| AppGW
    AppGW -->|4. Route to LB| LB
    LB -->|5. Load Balance| WebVM1
    LB -->|5. Load Balance| WebVM2
    WebVM1 -->|6. DNS Query: api.internal| PrivateDNS
    PrivateDNS -->|7. Resolve to 10.0.2.10| WebVM1
    WebVM1 -->|8. API Call| AppVM1
    AppVM1 -->|9. DNS Query: db.internal| PrivateDNS
    PrivateDNS -->|10. Resolve to 10.0.3.10| AppVM1
    AppVM1 -->|11. DB Query| DB
```

---

## Hybrid Cloud Architecture

### Complete Hybrid Architecture with VPN Gateway, DNS, and Private Link

This diagram shows how on-premises and Azure resources communicate through VPN Gateway with DNS resolution.

```mermaid
graph TB
    subgraph "On-Premises Network"
        OnPremDNS[On-Premises DNS<br/>192.168.1.10]
        OnPremApp[On-Prem App<br/>192.168.1.100<br/>onprem-app.local]
        OnPremUser[On-Prem User]
    end
    
    subgraph "VPN Gateway"
        VPNGW[VPN Gateway<br/>Public IP: 20.1.2.4]
        VPNConnection[Site-to-Site VPN<br/>Encrypted Tunnel]
    end
    
    subgraph "Azure VNet: Hub (10.0.0.0/16)"
        HubDNS[Azure DNS<br/>168.63.129.16]
        HubPrivateDNS[Private DNS Zone<br/>azure.internal]
        
        subgraph "Gateway Subnet (10.0.4.0/24)"
            VPNGWPrivate[VPN Gateway<br/>Private IP: 10.0.4.4]
        end
        
        subgraph "Shared Services Subnet (10.0.5.0/24)"
            AzureApp[Azure App<br/>10.0.5.10<br/>azure-app.azure.internal]
        end
    end
    
    subgraph "Azure VNet: Spoke (10.1.0.0/16)"
        SpokePrivateDNS[Private DNS Zone<br/>azure.internal<br/>Linked to Spoke]
        SpokeVM[Spoke VM<br/>10.1.1.10<br/>spoke-vm.azure.internal]
    end
    
    subgraph "Azure Services"
        Storage[Storage Account<br/>Private Endpoint<br/>10.0.6.10<br/>storage.azure.internal]
    end
    
    OnPremUser -->|1. DNS Query: azure-app.azure.internal| OnPremDNS
    OnPremDNS -->|2. Forward to Azure| HubDNS
    HubDNS -->|3. Resolve to 10.0.5.10| HubPrivateDNS
    OnPremDNS -->|4. Return IP| OnPremUser
    OnPremUser -->|5. Request via VPN| VPNConnection
    VPNConnection -->|6. Encrypted Tunnel| VPNGW
    VPNGW -->|7. Route to VNet| AzureApp
    
    OnPremApp -->|8. DNS Query: storage.azure.internal| OnPremDNS
    OnPremDNS -->|9. Forward| HubDNS
    HubDNS -->|10. Resolve to Private Endpoint| Storage
    OnPremApp -->|11. Connect via Private Link| Storage
    
    SpokeVM -->|12. DNS Query: onprem-app.local| SpokePrivateDNS
    SpokePrivateDNS -->|13. Forward via VPN| OnPremDNS
    OnPremDNS -->|14. Resolve to 192.168.1.100| SpokeVM
    SpokeVM -->|15. Connect via VPN| OnPremApp
```

**Communication Flow:**

```mermaid
sequenceDiagram
    participant OnPrem as On-Premises App
    participant OnPremDNS as On-Prem DNS
    participant VPN as VPN Gateway
    participant AzureDNS as Azure DNS
    participant AzureApp as Azure App
    participant Storage as Storage Account<br/>(Private Endpoint)
    
    OnPrem->>OnPremDNS: 1. DNS Query: azure-app.azure.internal
    OnPremDNS->>AzureDNS: 2. Forward Query via VPN
    AzureDNS->>OnPremDNS: 3. Return IP: 10.0.5.10
    OnPremDNS->>OnPrem: 4. Return IP
    
    OnPrem->>VPN: 5. Connect to 10.0.5.10
    VPN->>VPN: 6. Decrypt & Route
    VPN->>AzureApp: 7. Forward Request
    
    AzureApp->>AzureDNS: 8. DNS Query: storage.azure.internal
    AzureDNS->>AzureApp: 9. Return Private Endpoint IP: 10.0.6.10
    AzureApp->>Storage: 10. Connect via Private Link<br/>(Private IP, No Internet)
    
    Storage->>AzureApp: 11. Return Data
    AzureApp->>VPN: 12. Return Response
    VPN->>OnPrem: 13. Encrypt & Forward
```

---

## Global Distribution Architecture

### Complete Global Architecture with Front Door, Traffic Manager, and DNS

This diagram shows how global applications use DNS, Traffic Manager, and Front Door for worldwide distribution.

```mermaid
graph TB
    subgraph "Global Users"
        UserUS[User: US]
        UserEU[User: Europe]
        UserASIA[User: Asia]
    end
    
    subgraph "DNS Layer"
        PublicDNS[Azure DNS<br/>example.com]
        TrafficManagerDNS[Traffic Manager<br/>example.trafficmanager.net]
    end
    
    subgraph "Azure Front Door (Global Edge)"
        FrontDoor[Azure Front Door<br/>example.azurefd.net]
        FrontDoorWAF[WAF Protection]
        FrontDoorCache[Edge Caching]
        
        subgraph "Front Door Backends"
            USBackend[US East Backend]
            EUBackend[West Europe Backend]
            ASIABackend[Southeast Asia Backend]
        end
    end
    
    subgraph "US East Region"
        USAppGW[Application Gateway<br/>us-east.example.com]
        USVMs[Web VMs]
    end
    
    subgraph "West Europe Region"
        EUAppGW[Application Gateway<br/>eu-west.example.com]
        EUVMs[Web VMs]
    end
    
    subgraph "Southeast Asia Region"
        ASIAAppGW[Application Gateway<br/>asia-se.example.com]
        ASIAVMs[Web VMs]
    end
    
    UserUS -->|1. DNS Query: www.example.com| PublicDNS
    PublicDNS -->|2. CNAME to Traffic Manager| TrafficManagerDNS
    TrafficManagerDNS -->|3. Performance Routing: Return US IP| UserUS
    UserUS -->|4. Request to Front Door US Edge| FrontDoor
    FrontDoor -->|5. Route to Nearest Backend| USBackend
    USBackend -->|6. Forward to App Gateway| USAppGW
    USAppGW -->|7. Load Balance| USVMs
    
    UserEU -->|1. DNS Query| PublicDNS
    PublicDNS -->|2. CNAME| TrafficManagerDNS
    TrafficManagerDNS -->|3. Return EU IP| UserEU
    UserEU -->|4. Request to Front Door EU Edge| FrontDoor
    FrontDoor -->|5. Route to EU Backend| EUBackend
    EUBackend -->|6. Forward| EUAppGW
    EUAppGW -->|7. Load Balance| EUVMs
    
    UserASIA -->|1. DNS Query| PublicDNS
    PublicDNS -->|2. CNAME| TrafficManagerDNS
    TrafficManagerDNS -->|3. Return Asia IP| UserASIA
    UserASIA -->|4. Request to Front Door Asia Edge| FrontDoor
    FrontDoor -->|5. Route to Asia Backend| ASIABackend
    ASIABackend -->|6. Forward| ASIAAppGW
    ASIAAppGW -->|7. Load Balance| ASIAVMs
```

**Traffic Flow Sequence:**

```mermaid
sequenceDiagram
    participant User
    participant DNS as Public DNS
    participant TM as Traffic Manager
    participant FD as Front Door
    participant AppGW as Application Gateway
    participant VM as Web VM
    participant CDN as Azure CDN
    
    User->>DNS: 1. DNS Query: www.example.com
    DNS->>TM: 2. CNAME: example.trafficmanager.net
    TM->>TM: 3. Performance Routing<br/>Calculate Latency
    TM->>User: 4. Return IP: Front Door Edge<br/>(Nearest Region)
    
    User->>FD: 5. HTTPS Request
    FD->>FD: 6. WAF Inspection
    FD->>FD: 7. Check Cache
    
    alt Cache Hit
        FD->>User: 8. Return Cached Content
    else Cache Miss
        FD->>AppGW: 9. Forward to App Gateway
        AppGW->>VM: 10. Load Balance to VM
        VM->>CDN: 11. Request Static Assets
        CDN->>VM: 12. Return Assets
        VM->>AppGW: 13. Return Dynamic Content
        AppGW->>FD: 14. Return Response
        FD->>FD: 15. Cache Response
        FD->>User: 16. Return Content
    end
```

---

## Hub-Spoke Architecture

### Complete Hub-Spoke Architecture with Firewall, DNS, and Private Link

This diagram shows a hub-spoke architecture with centralized security and DNS.

```mermaid
graph TB
    subgraph "Internet"
        InternetUsers[Internet Users]
    end
    
    subgraph "Hub VNet (10.0.0.0/16)"
        HubDNS[Azure DNS<br/>168.63.129.16]
        HubPrivateDNS[Private DNS Zone<br/>company.internal]
        
        subgraph "Firewall Subnet (10.0.0.0/26)"
            Firewall[Azure Firewall<br/>10.0.0.4]
            FirewallPublicIP[Firewall Public IP<br/>20.1.2.5]
        end
        
        subgraph "Bastion Subnet (10.0.0.64/26)"
            Bastion[Azure Bastion<br/>10.0.0.68]
        end
        
        subgraph "Gateway Subnet (10.0.0.128/27)"
            VPNGW[VPN Gateway<br/>10.0.0.132]
        end
        
        RouteTable[Route Table<br/>0.0.0.0/0 → Firewall]
    end
    
    subgraph "Spoke 1 VNet (10.1.0.0/16)"
        Spoke1DNS[Private DNS Zone<br/>company.internal<br/>Linked]
        Spoke1VM[Spoke 1 VM<br/>10.1.1.10<br/>spoke1-vm.company.internal]
    end
    
    subgraph "Spoke 2 VNet (10.2.0.0/16)"
        Spoke2DNS[Private DNS Zone<br/>company.internal<br/>Linked]
        Spoke2VM[Spoke 2 VM<br/>10.2.1.10<br/>spoke2-vm.company.internal]
    end
    
    subgraph "Azure Services"
        Storage[Storage Account<br/>Private Endpoint<br/>10.0.1.10<br/>storage.company.internal]
    end
    
    InternetUsers -->|1. Request| FirewallPublicIP
    FirewallPublicIP -->|2. NAT Rule| Firewall
    Firewall -->|3. Application Rule<br/>Check FQDN| Firewall
    Firewall -->|4. Route via Route Table| Spoke1VM
    
    Spoke1VM -->|5. DNS Query: storage.company.internal| Spoke1DNS
    Spoke1DNS -->|6. Resolve via Hub| HubPrivateDNS
    HubPrivateDNS -->|7. Return Private Endpoint IP| Spoke1VM
    Spoke1VM -->|8. Connect via Private Link| Storage
    
    Spoke1VM -->|9. DNS Query: spoke2-vm.company.internal| Spoke1DNS
    Spoke1DNS -->|10. Resolve| HubPrivateDNS
    HubPrivateDNS -->|11. Return IP: 10.2.1.10| Spoke1VM
    Spoke1VM -->|12. Connect via VNet Peering| Spoke2VM
    
    Spoke1VM -->|13. Outbound Internet| Firewall
    Firewall -->|14. Network Rule Check| Firewall
    Firewall -->|15. Allow/Deny| InternetUsers
```

**Hub-Spoke Communication Flow:**

```mermaid
sequenceDiagram
    participant Spoke1 as Spoke 1 VM
    participant Spoke1DNS as Spoke 1 DNS
    participant HubDNS as Hub DNS
    participant Firewall as Azure Firewall
    participant Storage as Storage Account
    participant Spoke2 as Spoke 2 VM
    participant Internet as Internet
    
    Note over Spoke1,Storage: Private Link Communication
    Spoke1->>Spoke1DNS: 1. DNS Query: storage.company.internal
    Spoke1DNS->>HubDNS: 2. Forward to Hub
    HubDNS->>Spoke1DNS: 3. Return Private Endpoint: 10.0.1.10
    Spoke1DNS->>Spoke1: 4. Return IP
    Spoke1->>Storage: 5. Connect via Private Link<br/>(Private IP, No Firewall)
    
    Note over Spoke1,Spoke2: Spoke-to-Spoke Communication
    Spoke1->>Spoke1DNS: 6. DNS Query: spoke2-vm.company.internal
    Spoke1DNS->>HubDNS: 7. Forward to Hub
    HubDNS->>Spoke1DNS: 8. Return IP: 10.2.1.10
    Spoke1DNS->>Spoke1: 9. Return IP
    Spoke1->>Spoke2: 10. Connect via VNet Peering<br/>(Direct, No Firewall)
    
    Note over Spoke1,Internet: Internet Communication
    Spoke1->>Firewall: 11. Outbound Request
    Firewall->>Firewall: 12. Application Rule: Check FQDN
    Firewall->>Firewall: 13. Network Rule: Check IP/Port
    Firewall->>Internet: 14. Allow/Deny Based on Rules
    Internet->>Firewall: 15. Response
    Firewall->>Spoke1: 16. Return Response
```

---

## DNS Resolution Flows

### Complete DNS Resolution Architecture

This diagram shows how DNS resolution works across different scenarios in Azure.

```mermaid
graph TB
    subgraph "Client: Azure VM"
        VM[VM in VNet<br/>10.0.1.10]
    end
    
    subgraph "DNS Resolution Path"
        AzureDNS[Azure DNS<br/>168.63.129.16<br/>Default]
        PrivateDNS[Private DNS Zone<br/>internal.company.local]
        CustomDNS[Custom DNS Server<br/>10.0.5.10]
        OnPremDNS[On-Premises DNS<br/>192.168.1.10]
    end
    
    subgraph "Target Resources"
        LocalVM[Local VM<br/>10.0.2.10<br/>local-vm.internal]
        PrivateEndpoint[Private Endpoint<br/>10.0.3.10<br/>storage.internal]
        PublicService[Public Service<br/>api.example.com]
        OnPremService[On-Prem Service<br/>192.168.1.100<br/>onprem-app.local]
    end
    
    VM -->|1. Query: local-vm.internal| AzureDNS
    AzureDNS -->|2. Check Private DNS| PrivateDNS
    PrivateDNS -->|3. Return: 10.0.2.10| VM
    VM -->|4. Connect| LocalVM
    
    VM -->|5. Query: storage.internal| AzureDNS
    AzureDNS -->|6. Check Private DNS| PrivateDNS
    PrivateDNS -->|7. Return Private Endpoint: 10.0.3.10| VM
    VM -->|8. Connect via Private Link| PrivateEndpoint
    
    VM -->|9. Query: api.example.com| AzureDNS
    AzureDNS -->|10. Forward to Internet DNS| PublicService
    PublicService -->|11. Return Public IP| VM
    VM -->|12. Connect via Internet| PublicService
    
    VM -->|13. Query: onprem-app.local| CustomDNS
    CustomDNS -->|14. Forward via VPN| OnPremDNS
    OnPremDNS -->|15. Return: 192.168.1.100| VM
    VM -->|16. Connect via VPN| OnPremService
```

**DNS Resolution Sequence:**

```mermaid
sequenceDiagram
    participant VM as Azure VM
    participant AzureDNS as Azure DNS
    participant PrivateDNS as Private DNS Zone
    participant CustomDNS as Custom DNS
    participant OnPremDNS as On-Prem DNS
    participant Target as Target Resource
    
    Note over VM,Target: Scenario 1: Internal VNet Resolution
    VM->>AzureDNS: 1. Query: vm-01.internal
    AzureDNS->>PrivateDNS: 2. Check Private Zone
    PrivateDNS->>AzureDNS: 3. Return: 10.0.1.10
    AzureDNS->>VM: 4. Return IP
    VM->>Target: 5. Connect to 10.0.1.10
    
    Note over VM,Target: Scenario 2: Private Endpoint Resolution
    VM->>AzureDNS: 6. Query: storage.internal
    AzureDNS->>PrivateDNS: 7. Check Private Zone
    PrivateDNS->>AzureDNS: 8. Return Private Endpoint: 10.0.3.10
    AzureDNS->>VM: 9. Return IP
    VM->>Target: 10. Connect via Private Link
    
    Note over VM,Target: Scenario 3: Hybrid DNS Resolution
    VM->>CustomDNS: 11. Query: onprem-app.local
    CustomDNS->>OnPremDNS: 12. Forward via VPN
    OnPremDNS->>CustomDNS: 13. Return: 192.168.1.100
    CustomDNS->>VM: 14. Return IP
    VM->>Target: 15. Connect via VPN
```

---

## Security Architecture

### Complete Security Architecture with Firewall, WAF, and DNS

This diagram shows how security services work together with DNS.

```mermaid
graph TB
    subgraph "Internet"
        Attacker[Potential Attacker]
        LegitUser[Legitimate User]
    end
    
    subgraph "DDoS Protection"
        DDoS[DDoS Protection<br/>Standard]
    end
    
    subgraph "Front Door (Edge)"
        FrontDoor[Azure Front Door<br/>www.example.com]
        FrontDoorWAF[WAF Rules<br/>OWASP Top 10]
        FrontDoorDNS[Front Door DNS<br/>example.azurefd.net]
    end
    
    subgraph "Application Gateway"
        AppGW[Application Gateway<br/>WAF Enabled]
        AppGWWAF[WAF Rules<br/>Custom Rules]
    end
    
    subgraph "Hub VNet (10.0.0.0/16)"
        Firewall[Azure Firewall<br/>10.0.0.4]
        FirewallDNS[Firewall DNS<br/>Custom: 10.0.5.10]
        
        subgraph "Application Rule"
            AppRule[Allow: *.blob.core.windows.net<br/>Deny: *.malicious.com]
        end
        
        subgraph "Network Rule"
            NetRule[Allow: 10.0.0.0/16<br/>Deny: 0.0.0.0/0]
        end
    end
    
    subgraph "Application VNet (10.1.0.0/16)"
        AppVM[Application VM<br/>10.1.1.10]
    end
    
    LegitUser -->|1. DNS Query: www.example.com| FrontDoorDNS
    FrontDoorDNS -->|2. Return Front Door IP| LegitUser
    LegitUser -->|3. HTTPS Request| FrontDoor
    FrontDoor -->|4. DDoS Protection| DDoS
    DDoS -->|5. Mitigate Attack| FrontDoor
    FrontDoor -->|6. WAF Inspection| FrontDoorWAF
    FrontDoorWAF -->|7. Allow Legitimate| AppGW
    AppGW -->|8. WAF Inspection| AppGWWAF
    AppGWWAF -->|9. Allow| Firewall
    Firewall -->|10. DNS Query: api.example.com| FirewallDNS
    FirewallDNS -->|11. Resolve FQDN| Firewall
    Firewall -->|12. Application Rule Check| AppRule
    AppRule -->|13. Allow| AppVM
    
    Attacker -->|1. DNS Query| FrontDoorDNS
    FrontDoorDNS -->|2. Return IP| Attacker
    Attacker -->|3. DDoS Attack| FrontDoor
    FrontDoor -->|4. DDoS Protection| DDoS
    DDoS -->|5. Block Attack| Attacker
    
    Attacker -->|6. SQL Injection Attempt| FrontDoor
    FrontDoor -->|7. WAF Detection| FrontDoorWAF
    FrontDoorWAF -->|8. Block Request| Attacker
```

**Security Flow Sequence:**

```mermaid
sequenceDiagram
    participant User
    participant DNS as DNS
    participant DDoS as DDoS Protection
    participant FD as Front Door + WAF
    participant AppGW as App Gateway + WAF
    participant Firewall as Azure Firewall
    participant App as Application
    
    User->>DNS: 1. DNS Query: www.example.com
    DNS->>User: 2. Return IP
    
    User->>FD: 3. HTTPS Request
    FD->>DDoS: 4. Check for DDoS
    DDoS->>FD: 5. Allow (No Attack)
    
    FD->>FD: 6. WAF: Check OWASP Rules
    alt Attack Detected
        FD->>User: 7. Block Request (403)
    else Legitimate
        FD->>AppGW: 8. Forward Request
        AppGW->>AppGW: 9. WAF: Check Custom Rules
        AppGW->>Firewall: 10. Forward Request
        
        Firewall->>DNS: 11. DNS Query: api.example.com
        DNS->>Firewall: 12. Resolve FQDN
        Firewall->>Firewall: 13. Application Rule: Check FQDN
        Firewall->>Firewall: 14. Network Rule: Check IP/Port
        
        alt Allowed
            Firewall->>App: 15. Forward Request
            App->>Firewall: 16. Return Response
            Firewall->>AppGW: 17. Return Response
            AppGW->>FD: 18. Return Response
            FD->>User: 19. Return Response
        else Denied
            Firewall->>AppGW: 15. Block Request
            AppGW->>FD: 16. Return Error
            FD->>User: 17. Return Error
        end
    end
```

---

## Load Balancing Flows

### Complete Load Balancing Architecture with DNS

This diagram shows how different load balancing services work together with DNS.

```mermaid
graph TB
    subgraph "Users"
        User1[User 1: US]
        User2[User 2: Europe]
        User3[User 3: Asia]
    end
    
    subgraph "DNS Layer"
        PublicDNS[Azure DNS<br/>example.com]
        TrafficManager[Traffic Manager<br/>example.trafficmanager.net<br/>Performance Routing]
    end
    
    subgraph "Front Door (Global)"
        FrontDoor[Azure Front Door<br/>Global Edge Network]
    end
    
    subgraph "Region: US East"
        USAppGW[Application Gateway<br/>us-east.example.com]
        USLB[Load Balancer<br/>10.0.1.100]
        USVM1[VM 1: 10.0.1.10]
        USVM2[VM 2: 10.0.1.11]
        USVM3[VM 3: 10.0.1.12]
    end
    
    subgraph "Region: West Europe"
        EUAppGW[Application Gateway<br/>eu-west.example.com]
        EULB[Load Balancer<br/>10.1.1.100]
        EUVM1[VM 1: 10.1.1.10]
        EUVM2[VM 2: 10.1.1.11]
    end
    
    User1 -->|1. DNS Query| PublicDNS
    PublicDNS -->|2. CNAME| TrafficManager
    TrafficManager -->|3. Performance: US East| User1
    User1 -->|4. Request| FrontDoor
    FrontDoor -->|5. Route to US| USAppGW
    USAppGW -->|6. Load Balance| USLB
    USLB -->|7. Round-Robin| USVM1
    USLB -->|7. Round-Robin| USVM2
    USLB -->|7. Round-Robin| USVM3
    
    User2 -->|1. DNS Query| PublicDNS
    PublicDNS -->|2. CNAME| TrafficManager
    TrafficManager -->|3. Performance: Europe| User2
    User2 -->|4. Request| FrontDoor
    FrontDoor -->|5. Route to EU| EUAppGW
    EUAppGW -->|6. Load Balance| EULB
    EULB -->|7. Round-Robin| EUVM1
    EULB -->|7. Round-Robin| EUVM2
```

**Load Balancing Flow Sequence:**

```mermaid
sequenceDiagram
    participant User
    participant DNS as DNS
    participant TM as Traffic Manager
    participant FD as Front Door
    participant AppGW as Application Gateway
    participant LB as Load Balancer
    participant VM1 as VM 1
    participant VM2 as VM 2
    participant Health as Health Probe
    
    User->>DNS: 1. DNS Query: www.example.com
    DNS->>TM: 2. CNAME: example.trafficmanager.net
    TM->>TM: 3. Performance Routing<br/>Calculate Latency
    TM->>User: 4. Return: Front Door IP<br/>(Nearest Region)
    
    User->>FD: 5. HTTPS Request
    FD->>FD: 6. Route to Nearest Backend
    FD->>AppGW: 7. Forward Request
    
    AppGW->>AppGW: 8. Host-based Routing
    AppGW->>LB: 9. Forward to Load Balancer
    
    LB->>Health: 10. Health Probe Check
    Health->>VM1: 11. Health Check
    VM1->>Health: 12. Healthy (200 OK)
    Health->>VM2: 13. Health Check
    VM2->>Health: 14. Healthy (200 OK)
    Health->>LB: 15. Both VMs Healthy
    
    LB->>LB: 16. Round-Robin Selection
    LB->>VM1: 17. Route Request
    VM1->>LB: 18. Return Response
    LB->>AppGW: 19. Return Response
    AppGW->>FD: 20. Return Response
    FD->>User: 21. Return Response
```

---

## NAT Gateway and Outbound Connectivity

### Complete Outbound Connectivity Architecture with DNS

This diagram shows how NAT Gateway provides outbound connectivity with DNS resolution.

```mermaid
graph TB
    subgraph "VNet Subnet (10.0.1.0/24)"
        VM1[VM 1<br/>10.0.1.10<br/>No Public IP]
        VM2[VM 2<br/>10.0.1.11<br/>No Public IP]
        VM3[VM 3<br/>10.0.1.12<br/>No Public IP]
    end
    
    subgraph "NAT Gateway"
        NAT[NAT Gateway<br/>Public IP: 20.1.2.6]
        NATPool[NAT Pool<br/>64,000 flows/IP]
    end
    
    subgraph "DNS Resolution"
        AzureDNS[Azure DNS<br/>168.63.129.16]
        InternetDNS[Internet DNS<br/>8.8.8.8]
    end
    
    subgraph "Internet Services"
        GitHub[GitHub API<br/>api.github.com]
        AzureService[Azure Service<br/>storage.blob.core.windows.net]
        ExternalAPI[External API<br/>api.example.com]
    end
    
    VM1 -->|1. DNS Query: api.github.com| AzureDNS
    AzureDNS -->|2. Forward to Internet| InternetDNS
    InternetDNS -->|3. Return IP: 140.82.121.3| VM1
    VM1 -->|4. Outbound Request<br/>Source: 10.0.1.10| NAT
    NAT -->|5. SNAT Translation<br/>Source: 20.1.2.6| GitHub
    GitHub -->|6. Response| NAT
    NAT -->|7. Return to VM1| VM1
    
    VM2 -->|8. DNS Query: storage.blob.core.windows.net| AzureDNS
    AzureDNS -->|9. Resolve Azure Service| AzureService
    AzureService -->|10. Return IP| VM2
    VM2 -->|11. Outbound Request| NAT
    NAT -->|12. SNAT Translation| AzureService
    AzureService -->|13. Response| NAT
    NAT -->|14. Return to VM2| VM2
```

**NAT Gateway Flow Sequence:**

```mermaid
sequenceDiagram
    participant VM as VM (No Public IP)
    participant DNS as Azure DNS
    participant NAT as NAT Gateway
    participant Internet as Internet Service
    
    VM->>DNS: 1. DNS Query: api.example.com
    DNS->>Internet: 2. Forward DNS Query
    Internet->>DNS: 3. Return IP: 203.0.113.10
    DNS->>VM: 4. Return IP
    
    VM->>NAT: 5. Outbound Request<br/>Source: 10.0.1.10:50000<br/>Dest: 203.0.113.10:443
    NAT->>NAT: 6. SNAT Translation<br/>Source: 20.1.2.6:1024<br/>Dest: 203.0.113.10:443
    NAT->>Internet: 7. Request from NAT IP
    Internet->>NAT: 8. Response to NAT IP
    NAT->>NAT: 9. Reverse SNAT<br/>Source: 203.0.113.10:443<br/>Dest: 10.0.1.10:50000
    NAT->>VM: 10. Return Response
```

---

## Private Link and DNS Integration

### Complete Private Link Architecture with DNS

This diagram shows how Private Link integrates with DNS for seamless service access.

```mermaid
graph TB
    subgraph "VNet: Production (10.0.0.0/16)"
        VM1[VM 1<br/>10.0.1.10]
        VM2[VM 2<br/>10.0.1.11]
        PrivateDNS[Private DNS Zone<br/>privatelink.blob.core.windows.net]
    end
    
    subgraph "VNet: Development (10.1.0.0/16)"
        DevVM[Dev VM<br/>10.1.1.10]
        DevPrivateDNS[Private DNS Zone<br/>privatelink.blob.core.windows.net<br/>Linked]
    end
    
    subgraph "Storage Account"
        StoragePublic[Public Endpoint<br/>mystorage.blob.core.windows.net<br/>Public IP: 20.1.2.7]
        PrivateEndpoint[Private Endpoint<br/>10.0.2.10<br/>mystorage.privatelink.blob.core.windows.net]
    end
    
    subgraph "SQL Database"
        SQLPublic[Public Endpoint<br/>myserver.database.windows.net<br/>Public IP: 20.1.2.8]
        SQLPrivateEndpoint[Private Endpoint<br/>10.0.2.11<br/>myserver.privatelink.database.windows.net]
    end
    
    VM1 -->|1. DNS Query: mystorage.blob.core.windows.net| PrivateDNS
    PrivateDNS -->|2. Check Private Endpoint| PrivateEndpoint
    PrivateDNS -->|3. Return Private IP: 10.0.2.10| VM1
    VM1 -->|4. Connect via Private Link<br/>(No Internet)| PrivateEndpoint
    
    DevVM -->|5. DNS Query: mystorage.blob.core.windows.net| DevPrivateDNS
    DevPrivateDNS -->|6. Check Private Endpoint| PrivateEndpoint
    DevPrivateDNS -->|7. Return Private IP: 10.0.2.10| DevVM
    DevVM -->|8. Connect via Private Link| PrivateEndpoint
    
    VM2 -->|9. DNS Query: myserver.database.windows.net| PrivateDNS
    PrivateDNS -->|10. Check Private Endpoint| SQLPrivateEndpoint
    PrivateDNS -->|11. Return Private IP: 10.0.2.11| VM2
    VM2 -->|12. Connect via Private Link| SQLPrivateEndpoint
```

**Private Link DNS Flow:**

```mermaid
sequenceDiagram
    participant VM as VM in VNet
    participant DNS as Private DNS Zone
    participant Service as Azure Service<br/>(Storage/SQL)
    participant PrivateEP as Private Endpoint
    
    VM->>DNS: 1. DNS Query: mystorage.blob.core.windows.net
    DNS->>DNS: 2. Check Private DNS Zone
    DNS->>DNS: 3. Find A Record: Private Endpoint
    DNS->>VM: 4. Return Private IP: 10.0.2.10<br/>(Not Public IP)
    
    VM->>PrivateEP: 5. Connect to Private IP<br/>(10.0.2.10:443)
    PrivateEP->>Service: 6. Forward via Private Link<br/>(Azure Backbone)
    Service->>PrivateEP: 7. Return Data
    PrivateEP->>VM: 8. Return Response
    
    Note over VM,Service: All traffic stays on Azure's<br/>private network backbone
```

---

## Complete Enterprise Architecture

### Full Enterprise Architecture with All Services

This comprehensive diagram shows how all Azure networking services work together in an enterprise scenario.

```mermaid
graph TB
    subgraph "Internet"
        Users[Global Users]
        OnPremUsers[On-Premises Users]
    end
    
    subgraph "DNS Infrastructure"
        PublicDNS[Azure DNS<br/>Public Zones]
        PrivateDNS[Private DNS Zones]
        TrafficManager[Traffic Manager<br/>DNS-based Routing]
    end
    
    subgraph "Global Edge"
        FrontDoor[Azure Front Door<br/>WAF + CDN]
        DDoS[DDoS Protection]
    end
    
    subgraph "Hub VNet (10.0.0.0/16)"
        Firewall[Azure Firewall<br/>Centralized Security]
        VPNGW[VPN Gateway<br/>Hybrid Connectivity]
        Bastion[Azure Bastion<br/>Secure VM Access]
        NAT[NAT Gateway<br/>Outbound Connectivity]
        
        subgraph "Private DNS Zone"
            HubPrivateDNS[company.internal]
        end
    end
    
    subgraph "Spoke 1: Web (10.1.0.0/16)"
        AppGW1[Application Gateway<br/>WAF]
        LB1[Load Balancer]
        WebVMs[Web VMs]
    end
    
    subgraph "Spoke 2: Data (10.2.0.0/16)"
        DBVMs[Database VMs]
        Storage[Storage Account<br/>Private Endpoint]
    end
    
    subgraph "Azure Services"
        Services[Azure Services<br/>Private Link]
    end
    
    Users -->|1. DNS Query| PublicDNS
    PublicDNS -->|2. Traffic Manager| TrafficManager
    TrafficManager -->|3. Performance Routing| FrontDoor
    FrontDoor -->|4. DDoS Check| DDoS
    FrontDoor -->|5. WAF| Firewall
    Firewall -->|6. Application Rules| AppGW1
    AppGW1 -->|7. Load Balance| LB1
    LB1 -->|8. Route| WebVMs
    
    WebVMs -->|9. DNS Query: db.internal| HubPrivateDNS
    HubPrivateDNS -->|10. Resolve| DBVMs
    WebVMs -->|11. Connect| DBVMs
    
    WebVMs -->|12. DNS Query: storage.internal| HubPrivateDNS
    HubPrivateDNS -->|13. Resolve Private Endpoint| Storage
    WebVMs -->|14. Private Link| Storage
    
    WebVMs -->|15. Outbound Internet| NAT
    NAT -->|16. SNAT| Internet
    
    OnPremUsers -->|17. VPN Connection| VPNGW
    VPNGW -->|18. Route| Firewall
    Firewall -->|19. Allow| WebVMs
```

---

## Summary

These architectures demonstrate:

1. **DNS as Foundation**: DNS resolution is fundamental to all Azure networking services
2. **Layered Security**: Multiple security layers (DDoS, WAF, Firewall, NSG) work together
3. **Global Distribution**: DNS-based routing enables global application distribution
4. **Hybrid Connectivity**: DNS enables seamless name resolution across on-premises and cloud
5. **Private Connectivity**: Private Link uses DNS to provide seamless private access
6. **Service Discovery**: DNS enables dynamic service discovery without hardcoded IPs

All these architectures rely on proper DNS configuration for optimal performance, security, and maintainability.

