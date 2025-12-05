# Azure Virtual Networks

## Overview

A major incentive for adopting cloud solutions like Azure is to enable information technology departments to transition server resources to the cloud. Moving resources to the cloud can save money and simplify administrative operations. Relocating resources removes the need to maintain expensive datacenters with uninterruptible power supplies, generators, multiple fail-safes, or clustered database servers. For small and medium-sized companies, which might not have the expertise to maintain their own robust infrastructure, moving to the cloud is particularly appealing.

**Learn more:**
- [Azure Virtual Network Overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)

## Things to Know About Azure Virtual Networks

You can implement Azure Virtual Network to create a virtual representation of your network in the cloud. With some planning, you can deploy virtual networks and connect the resources you need more effectively. Let's examine some characteristics of virtual networks in Azure.

**Virtual Network Characteristics:**
```mermaid
graph TB
    VNet[Azure Virtual Network] --> Isolation[Logical Isolation<br/>Azure Cloud Resources]
    VNet --> VPN[VPN Provisioning<br/>Virtual Private Networks]
    VNet --> CIDR[CIDR Block<br/>Address Space]
    VNet --> DNS[DNS Server Settings<br/>Custom DNS]
    VNet --> Subnets[Subnet Segmentation]
    
    VNet --> OnPrem[On-Premises Connection]
    VNet --> OtherVNet[Other Virtual Networks]
```

**Key Characteristics:**

1. **Logical Isolation**: An Azure virtual network is a logical isolation of the Azure cloud resources.

2. **VPN Provisioning**: You can use virtual networks to provision and manage virtual private networks (VPNs) in Azure.

3. **CIDR Blocks**: Each virtual network has its own Classless Inter-Domain Routing (CIDR) block and can be linked to other virtual networks and on-premises networks.

4. **Hybrid Connectivity**: You can link virtual networks with an on-premises IT infrastructure to create hybrid or cross-premises solutions, when the CIDR blocks of the connecting networks don't overlap.

5. **DNS and Segmentation**: You control the DNS server settings for virtual networks, and segmentation of the virtual network into subnets.

**Virtual Network Architecture:**
```mermaid
graph TB
    subgraph "Azure Virtual Network"
        VNet[Virtual Network<br/>10.0.0.0/16]
        
        subgraph "Subnet (10.0.1.0/24)"
            VM1[Virtual Machine 1]
            VM2[Virtual Machine 2]
        end
    end
    
    VNet --> OnPrem[On-Premises Infrastructure<br/>VPN/ExpressRoute]
    VNet --> OtherVNet[Other Virtual Network<br/>VNet Peering]
    
    VM1 --> VM2
    VM1 --> OnPrem
    VM2 --> OtherVNet
```

## Things to Consider When Using Virtual Networks

Virtual networks can be used in many ways. As you think about the configuration plan for your virtual networks and subnets, consider the following scenarios.

| Scenario | Description |
|----------|-------------|
| **Create a dedicated private cloud-only virtual network** | Sometimes you don't require a cross-premises configuration for your solution. When you create a virtual network, your services and virtual machines within your virtual network can communicate directly and securely with each other in the cloud. You can still configure endpoint connections for the virtual machines and services that require internet communication, as part of your solution. |
| **Securely extend your data center with virtual networks** | You can build traditional site-to-site VPNs to securely scale your datacenter capacity. Site-to-site VPNs use IPSEC to provide a secure connection between your corporate VPN gateway and Azure. |
| **Enable hybrid cloud scenarios** | Virtual networks give you the flexibility to support a range of hybrid cloud scenarios. You can securely connect cloud-based applications to any type of on-premises system, such as mainframes and Unix systems. |

**Virtual Network Use Cases:**
```mermaid
graph TB
    VNet[Virtual Network] --> CloudOnly[Cloud-Only Network<br/>Private Communication]
    VNet --> ExtendDC[Extend Data Center<br/>Site-to-Site VPN]
    VNet --> Hybrid[Hybrid Cloud<br/>Connect Cloud to On-Premises]
    
    CloudOnly --> Direct[Direct VM Communication<br/>Secure in Cloud]
    ExtendDC --> IPSec[IPSec VPN<br/>Secure Connection]
    Hybrid --> Mainframe[Mainframe Systems]
    Hybrid --> Unix[Unix Systems]
    Hybrid --> Legacy[Legacy Systems]
```

## Create Subnets

Azure Subnets provide a way for you to implement logical divisions within your virtual network. Your network can be segmented into subnets to help improve security, increase performance, and make it easier to manage.

**Subnet Benefits:**
- **Security**: Improve security through network segmentation
- **Performance**: Increase performance through traffic isolation
- **Management**: Make network management easier
- **Organization**: Logical organization of resources

### Things to Know About Subnets

There are certain conditions for the IP addresses in a virtual network when you apply segmentation with subnets.

**Subnet Requirements:**
```mermaid
graph TB
    VNet[Virtual Network<br/>10.0.0.0/16] --> Subnet1[Subnet 1<br/>10.0.1.0/24]
    VNet --> Subnet2[Subnet 2<br/>10.0.2.0/24]
    VNet --> Subnet3[Subnet 3<br/>10.0.3.0/24]
    
    Subnet1 --> Unique1[Unique Address Range]
    Subnet2 --> Unique2[Unique Address Range]
    Subnet3 --> Unique3[Unique Address Range]
    
    Unique1 --> NoOverlap[No Overlap]
    Unique2 --> NoOverlap
    Unique3 --> NoOverlap
```

**Subnet IP Address Conditions:**

1. **Address Range Within VNet**: Each subnet contains a range of IP addresses that fall within the virtual network address space.

2. **Unique Range**: The address range for a subnet must be unique within the address space for the virtual network.

3. **No Overlap**: The range for one subnet can't overlap with other subnet IP address ranges in the same virtual network.

4. **CIDR Notation**: The IP address space for a subnet must be specified by using CIDR notation.

**Subnet Configuration Example:**
```
Virtual Network: 10.0.0.0/16

Subnet 1: 10.0.1.0/24  (10.0.1.0 - 10.0.1.255)
Subnet 2: 10.0.2.0/24  (10.0.2.0 - 10.0.2.255)
Subnet 3: 10.0.3.0/24  (10.0.3.0 - 10.0.3.255)
```

### Reserved Addresses

For each subnet, Azure reserves five IP addresses. The first four addresses and the last address are reserved.

**Reserved Addresses in 192.168.1.0/24:**

| Reserved Address | Reason |
|------------------|--------|
| **192.168.1.0** | This value identifies the virtual network address. |
| **192.168.1.1** | Azure configures this address as the default gateway. |
| **192.168.1.2** | Azure maps this Azure DNS IP address to the virtual network space. |
| **192.168.1.3** | Azure maps this Azure DNS IP address to the virtual network space. |
| **192.168.1.255** | This value supplies the virtual network broadcast address. |

**Reserved Addresses Visualization:**
```mermaid
graph LR
    Subnet[Subnet: 192.168.1.0/24<br/>256 Addresses Total] --> Reserved[5 Reserved Addresses]
    Subnet --> Usable[251 Usable Addresses]
    
    Reserved --> First[192.168.1.0<br/>Network Address]
    Reserved --> Gateway[192.168.1.1<br/>Default Gateway]
    Reserved --> DNS1[192.168.1.2<br/>Azure DNS]
    Reserved --> DNS2[192.168.1.3<br/>Azure DNS]
    Reserved --> Broadcast[192.168.1.255<br/>Broadcast Address]
```

**Important Considerations:**
- **Usable Addresses**: Total addresses minus 5 reserved = usable addresses
- **Example**: `/24` subnet (256 addresses) = 251 usable addresses
- **Planning**: Account for reserved addresses when planning subnet sizes

### Things to Consider When Using Subnets

When you plan for adding subnet segments within your virtual network, there are several factors to consider.

**Subnet Planning Considerations:**
```mermaid
graph TB
    Planning[Subnet Planning] --> ServiceReqs[Service Requirements]
    Planning --> NVA[Network Virtual Appliances]
    Planning --> NSG[Network Security Groups]
    Planning --> PrivateLink[Private Links]
    
    ServiceReqs --> GatewaySubnet[Gateway Subnet<br/>VPN/ExpressRoute]
    ServiceReqs --> ServiceSubnet[Service-Specific Subnets]
    
    NVA --> TrafficRouting[Traffic Routing<br/>Through NVA]
    
    NSG --> SecurityRules[Security Rules<br/>Per Subnet]
    
    PrivateLink --> PrivateConnectivity[Private Connectivity<br/>To PaaS Services]
```

#### Consider Service Requirements

Each service directly deployed into a virtual network has specific requirements for routing and the types of traffic that must be allowed into and out of associated subnets. A service might require or create their own subnet. There must be enough unallocated space to meet the service requirements.

**Service-Specific Subnets:**
- **Gateway Subnet**: Required for VPN Gateway or ExpressRoute Gateway
- **Application Gateway Subnet**: Dedicated subnet for Application Gateway
- **Azure Bastion Subnet**: Dedicated subnet for Azure Bastion
- **Azure Firewall Subnet**: Dedicated subnet for Azure Firewall

**Example**: Suppose you connect a virtual network to an on-premises network by using Azure VPN Gateway. The virtual network must have a dedicated subnet for the gateway.

#### Consider Network Virtual Appliances

Azure routes network traffic between all subnets in a virtual network, by default. You can override Azure's default routing to prevent Azure routing between subnets. You can also override the default to route traffic between subnets through a network virtual appliance. If you require traffic between resources in the same virtual network to flow through a network virtual appliance, deploy the resources to different subnets.

**NVA Routing Architecture:**
```mermaid
graph TB
    Subnet1[Subnet 1] --> DefaultRoute[Default Azure Routing]
    Subnet2[Subnet 2] --> DefaultRoute
    DefaultRoute --> Direct[Direct Communication]
    
    Subnet1 --> CustomRoute[Custom Route Table]
    Subnet2 --> CustomRoute
    CustomRoute --> NVA[Network Virtual Appliance]
    NVA --> Inspected[Inspected Traffic]
```

#### Consider Network Security Groups

You can associate zero or one network security group to each subnet in a virtual network. You can associate the same or a different network security group to each subnet. Each network security group contains rules that allow or deny traffic to and from sources and destinations.

**NSG Association:**
```mermaid
graph TB
    VNet[Virtual Network] --> Subnet1[Subnet 1]
    VNet --> Subnet2[Subnet 2]
    VNet --> Subnet3[Subnet 3]
    
    Subnet1 --> NSG1[NSG 1<br/>Web Tier Rules]
    Subnet2 --> NSG2[NSG 2<br/>App Tier Rules]
    Subnet3 --> NSG3[NSG 1<br/>Shared NSG]
    
    NSG1 --> Rules1[Allow HTTP/HTTPS<br/>Deny Other]
    NSG2 --> Rules2[Allow App Ports<br/>Deny Internet]
    NSG3 --> Rules3[Database Rules]
```

#### Consider Private Links

Azure Private Link provides private connectivity from a virtual network to Azure platform as a service (PaaS), customer-owned, or Microsoft partner services. Private Link simplifies the network architecture and secures the connection between endpoints in Azure. The service eliminates data exposure to the public internet.

**Private Link Architecture:**
```mermaid
graph TB
    VNet[Virtual Network] --> PrivateEndpoint[Private Endpoint<br/>In Subnet]
    PrivateEndpoint --> PrivateLink[Private Link]
    PrivateLink --> PaaS[Azure PaaS Service<br/>Storage, SQL, etc.]
    
    Internet[Internet] -.->|No Access| PaaS
    VNet -->|Private Connection| PaaS
```

## Create Virtual Networks

You can create new virtual networks at any time. You can also add virtual networks when you create a virtual machine.

### Things to Know About Creating Virtual Networks

Review these requirements for creating a virtual network.

**Virtual Network Creation Requirements:**
```mermaid
graph TB
    CreateVNet[Create Virtual Network] --> IPAddressSpace[Define IP Address Space]
    CreateVNet --> PlanAddressSpace[Plan Address Space]
    CreateVNet --> DefineSubnet[Define at Least One Subnet]
    
    IPAddressSpace --> CIDR[CIDR Notation<br/>e.g., 10.0.0.0/16]
    PlanAddressSpace --> NoOverlap[No Overlap with<br/>On-Premises or Cloud]
    DefineSubnet --> SubnetRange[Subnet Address Range<br/>Within VNet Space]
```

**Key Requirements:**

1. **IP Address Space**: When you create a virtual network, you need to define the IP address space for the network.

2. **Address Space Planning**: 
   - Plan to use an IP address space that's not already in use in your organization.
   - The address space for the network can be either on-premises or in the cloud, but not both.
   - Once you create the IP address space, it can't be changed. If you plan your address space for cloud-only virtual networks, you might later decide to connect an on-premises site.

3. **Subnet Requirements**:
   - To create a virtual network, you need to define at least one subnet.
   - Each subnet contains a range of IP addresses that fall within the virtual network address space.
   - The address range for each subnet must be unique within the address space for the virtual network.
   - The range for one subnet can't overlap with other subnet IP address ranges in the same virtual network.

**Virtual Network Creation Process:**
```mermaid
flowchart TD
    Start[Start: Create VNet] --> Subscription[Select Subscription]
    Subscription --> ResourceGroup[Select Resource Group]
    ResourceGroup --> Name[Enter VNet Name]
    Name --> Region[Select Region]
    Region --> AddressSpace[Define Address Space<br/>CIDR Block]
    AddressSpace --> Subnet[Define Subnet<br/>Address Range]
    Subnet --> Review[Review Configuration]
    Review --> Create[Create Virtual Network]
```

## IP Addresses

You can assign IP addresses to Azure resources to communicate with other Azure resources, your on-premises network, and the internet. There are two types of Azure IP addresses: private and public.

**IP Address Types:**
```mermaid
graph TB
    IPAddresses[Azure IP Addresses] --> Private[Private IP Address]
    IPAddresses --> Public[Public IP Address]
    
    Private --> Internal[Internal Communication<br/>VNet & On-Premises]
    Private --> VPN[VPN Gateway]
    Private --> ExpressRoute[ExpressRoute]
    
    Public --> Internet[Internet Communication]
    Public --> PublicServices[Public-Facing Services]
```

**Resource with Both IP Addresses:**
```mermaid
graph TB
    VM[Virtual Machine Resource] --> PrivateIP[Private IP Address<br/>10.0.1.10<br/>Internal Communication]
    VM --> PublicIP[Public IP Address<br/>20.1.1.1<br/>Internet Communication]
    
    PrivateIP --> VNet[Virtual Network]
    PrivateIP --> OnPrem[On-Premises]
    
    PublicIP --> Internet[Internet]
```

### Private IP Addresses

Private IP addresses enable communication within an Azure virtual network and your on-premises network. You create a private IP address for your resource when you use a VPN gateway or Azure ExpressRoute circuit to extend your network to Azure.

**Private IP Address Characteristics:**
- **Internal Communication**: Enables communication within Azure VNet
- **On-Premises Connectivity**: Works with VPN Gateway and ExpressRoute
- **Not Internet Accessible**: Not directly accessible from internet
- **Address Range**: From VNet/subnet address space

**Private IP Address Assignment:**

A private IP address is allocated from the address range of the virtual network subnet that a resource is deployed in. There are two options: dynamic and static.

**Dynamic Assignment:**
- Azure assigns the next available unassigned or unreserved IP address in the subnet's address range
- Dynamic assignment is the default allocation method
- Example: If addresses 10.0.0.4 through 10.0.0.9 are already assigned, Azure assigns 10.0.0.10 to a new resource

**Static Assignment:**
- You select and assign any unassigned or unreserved IP address in the subnet's address range
- Example: If subnet range is 10.0.0.0/16 and addresses 10.0.0.4 through 10.0.0.9 are assigned, you can assign any address between 10.0.0.10 and 10.0.255.254

**Private IP Address Assignment Flow:**
```mermaid
graph TB
    Resource[Azure Resource] --> Subnet[Subnet Address Range]
    Subnet --> Method{Assignment Method?}
    
    Method -->|Dynamic| AzureAssign[Azure Assigns<br/>Next Available IP]
    Method -->|Static| UserAssign[User Assigns<br/>Specific IP]
    
    AzureAssign --> Available[Check Available IPs]
    Available --> Assign[Assign IP Address]
    UserAssign --> Validate[Validate IP Available]
    Validate --> Assign
```

**Things to Consider When Associating Private IP Addresses:**

| Resource | Private IP Address Association | Dynamic IP Address | Static IP Address |
|----------|-------------------------------|-------------------|------------------|
| **Virtual machine** | NIC | Yes | Yes |
| **Internal load balancer** | Front-end configuration | Yes | Yes |
| **Application gateway** | Front-end configuration | Yes | Yes |

**When to Use Static Private IP Addresses:**

Static IP addresses don't change and are best for certain situations, such as:
- **DNS name resolution**: Where a change in the IP address requires updating host records
- **IP address-based security models**: That require apps or services to have a static IP address
- **TLS/SSL certificates**: Linked to an IP address
- **Firewall rules**: That allow or deny traffic by using IP address ranges
- **Role-based virtual machines**: Such as Domain Controllers and DNS servers

### Public IP Addresses

Public IP addresses allow your resource to communicate with the internet. You can create a public IP address to connect with Azure public-facing services.

**Public IP Address Characteristics:**
- **Internet Communication**: Enables communication with internet
- **Public-Facing Services**: Required for public-facing Azure services
- **SKU Options**: Basic or Standard SKU
- **IP Version**: IPv4 or IPv6 support

**Things to Consider When Creating a Public IP Address:**

To create a public IP address, configure these settings:

**IP Version:**
- Select to create an IPv4 or IPv6 address, or Both addresses

**SKU:**
- Select the SKU for the public IP address, including Basic or Standard
- The value must match the SKU of the Azure load balancer with which the address is used

**Name:**
- Enter a name to identify the IP address
- The name must be unique within the resource group you select

**IP Address Assignment:**

**Dynamic Addresses:**
- Assigned after a public IP address is associated to an Azure resource and is started for the first time
- Dynamic addresses can change if a resource such as a virtual machine is stopped (deallocated) and then restarted through Azure
- The address remains the same if a virtual machine is rebooted or stopped from within the guest OS
- When a public IP address resource is removed from a resource, the dynamic address is released

**Static Addresses:**
- Assigned when a public IP address is created
- Static addresses aren't released until a public IP address resource is deleted
- If the address isn't associated to a resource, you can change the assignment method after the address is created
- If the address is associated to a resource, you might not be able to change the assignment method

**Important Note:**
- If you select IPv6 for the IP version, the assignment method must be Dynamic for the Basic SKU
- Standard SKU addresses are Static for both IPv4 and IPv6 addresses

**Public IP Address Assignment Comparison:**
```mermaid
graph TB
    PublicIP[Public IP Address] --> Dynamic[Dynamic Assignment]
    PublicIP --> Static[Static Assignment]
    
    Dynamic --> Changes[Can Change<br/>On Stop/Start]
    Dynamic --> Released[Released on<br/>Resource Removal]
    
    Static --> Permanent[Permanent<br/>Until Deleted]
    Static --> Stable[Stable Address]
```

**Things to Consider When Associating Public IP Addresses:**

| Top-level Resource | IP Address Configuration |
|-------------------|------------------------|
| **Virtual machine** | Network interface configuration |
| **Virtual Network Gateway (VPN)** | Gateway IP configuration |
| **Virtual Network Gateway (ER)** | Gateway IP configuration |
| **NAT Gateway** | Gateway IP configuration |
| **Public Load Balancer** | Front-end configuration |
| **Application Gateway** | Front-end configuration |
| **Azure Firewall** | Front-end configuration |
| **Route Server** | Front-end configuration |
| **API Management** | Front-end configuration |
| **Bastion host** | Public IP configuration |

### Public IP Address SKU Features

**Standard SKU Features:**

| Feature | Standard SKU |
|---------|-------------|
| **Allocation method** | Static |
| **Security** | Secure by default model |
| **Available zones** | Supported. Standard IPs can be nonzonal, zonal, or zone-redundant |

**Public IP Address SKU Comparison:**
```mermaid
graph TB
    PublicIP[Public IP Address] --> Basic[Basic SKU]
    PublicIP --> Standard[Standard SKU]
    
    Basic --> Dynamic[Dynamic Assignment<br/>IPv4/IPv6]
    Basic --> LimitedZones[Limited Zone Support]
    
    Standard --> Static[Static Assignment<br/>IPv4/IPv6]
    Standard --> Zones[Zone Support<br/>Nonzonal, Zonal, Zone-Redundant]
    Standard --> Secure[Secure by Default]
```

## IP Address Assignment Summary

**IP Address Assignment Methods:**
```mermaid
graph TB
    IPAssignment[IP Address Assignment] --> Dynamic[Dynamic Assignment]
    IPAssignment --> Static[Static Assignment]
    
    Dynamic --> PrivateDynamic[Private: Azure Assigns<br/>Next Available]
    Dynamic --> PublicDynamic[Public: Assigned on Start<br/>Can Change]
    
    Static --> PrivateStatic[Private: User Specifies<br/>Permanent]
    Static --> PublicStatic[Public: Assigned on Create<br/>Permanent]
```

**Key Differences:**

| Aspect | Dynamic | Static |
|--------|---------|--------|
| **Private IP** | Azure assigns next available | User specifies |
| **Public IP (Basic)** | Assigned on start, can change | Assigned on create, permanent |
| **Public IP (Standard)** | Not available | Always static |
| **Use Case** | General resources | DNS, certificates, firewall rules |

## Best Practices

### Virtual Network Planning

1. **Address Space Planning**: 
   - Plan address space carefully before creation
   - Consider future growth and connectivity requirements
   - Ensure no overlap with on-premises networks

2. **Subnet Design**:
   - Create subnets based on security and management needs
   - Reserve space for service-specific subnets (gateway, etc.)
   - Account for reserved addresses in subnet sizing

3. **DNS Configuration**:
   - Configure custom DNS servers if needed
   - Plan DNS resolution for hybrid scenarios

### Subnet Planning

1. **Service Requirements**: Plan for service-specific subnets
2. **Security**: Use NSGs for subnet-level security
3. **Routing**: Consider NVA routing requirements
4. **Private Link**: Plan for Private Endpoint subnets

### IP Address Management

1. **Static IPs**: Use for DNS, certificates, firewall rules
2. **Dynamic IPs**: Use for general resources
3. **SKU Selection**: Use Standard SKU for production
4. **Zone Redundancy**: Use zone-redundant IPs for high availability

## Summary

Azure Virtual Networks provide:
- **Logical Isolation**: Isolated network environment for Azure resources
- **Subnet Segmentation**: Logical divisions for security and management
- **Hybrid Connectivity**: Connect to on-premises networks via VPN/ExpressRoute
- **IP Address Management**: Private and public IP address assignment
- **Flexible Configuration**: Support for various networking scenarios

**Key Takeaways:**
- Virtual networks provide logical isolation of Azure resources
- Subnets enable network segmentation and security
- Five IP addresses are reserved per subnet
- IP addresses can be dynamically or statically assigned
- Public IPs enable internet communication, private IPs enable internal communication

**Additional Resources:**
- [Virtual Network Quickstart](https://learn.microsoft.com/en-us/azure/virtual-network/quick-create-portal)
- [Virtual Network Best Practices](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-guide)
- [Subnet Planning Guide](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-guide#plan-for-subnets)
- [IP Address Management](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)


