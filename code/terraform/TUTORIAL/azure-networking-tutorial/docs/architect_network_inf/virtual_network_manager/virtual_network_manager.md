# Azure Virtual Network Manager

## Overview

Azure Virtual Network Manager (AVNM) is a centralized management service that simplifies network governance and configuration at scale across multiple subscriptions and regions. It provides unified management for connectivity, security, and routing configurations, making it ideal for large enterprises managing complex network topologies.

**Learn more:**
- [Azure Virtual Network Manager Overview](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview)
- [Virtual Network Manager Documentation](https://learn.microsoft.com/en-us/azure/virtual-network-manager/)

## What is Azure Virtual Network Manager?

Azure Virtual Network Manager is a centralized management service that enables you to **group, configure, deploy, and manage virtual networks globally across subscriptions and tenants**. As organizations scale their cloud infrastructure, managing multiple virtual networks across different regions and subscriptions becomes increasingly complex. Azure Virtual Network Manager addresses this challenge by providing a unified pane of glass for network administration.

With Virtual Network Manager, you can define network groups to identify and logically segment your virtual networks. Then you can determine the connectivity, security, and routing configurations you want and apply them across all the selected virtual networks in network groups at once, ensuring consistent network policies across your entire infrastructure.

**Key Capabilities:**
- **Centralize network governance** across multiple subscriptions and regions
- **Automate topology deployment** (hub-and-spoke, mesh)
- **Enforce security policies** with security admin rules
- **Manage routing configurations** consistently
- **Scale network management** without manual per-VNet configuration
- **Manage IP address space** and prevent conflicts
- **Troubleshoot connectivity** with reachability verification

**Reference:** [Azure Virtual Network Manager Overview](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview)

### Key Capabilities

1. **Connectivity Configuration**
   - Automatically create and maintain hub-and-spoke or mesh topologies
   - Manage VNet peering relationships at scale
   - Deploy connectivity configurations across multiple VNets simultaneously

2. **Security Admin Rules**
   - Organization-level security policies that override NSG rules
   - Centralized security rule management
   - Conflict resolution with priority-based evaluation

3. **Routing Configuration**
   - Centralized route table management
   - Consistent routing policies across VNets
   - Integration with Azure Route Server

4. **IP Address Management (IPAM)**
   - Track and manage IP address spaces
   - Automatically allocate non-overlapping IP address space from IP address pools
   - Prevent IP address conflicts across on-premises and multicloud environments
   - Verify IP address reachability and troubleshoot connectivity issues
   - Analyze reachability paths between Azure resources
   - Identify Azure policies and configurations disallowing network traffic

**IPAM and Reachability Verification:**
```mermaid
graph TB
    IPAM[IP Address Management] --> Allocate[Allocate IP Space<br/>from IP Pools]
    IPAM --> Track[Track IP Address Spaces]
    IPAM --> Prevent[Prevent IP Conflicts<br/>On-Premises & Multi-Cloud]
    
    Reachability[Reachability Verification] --> Analyze[Analyze Reachability Paths]
    Reachability --> Identify[Identify Blocking Policies]
    Reachability --> Troubleshoot[Troubleshoot Connectivity]
    
    IPAM --> Reachability
    Reachability --> Resources[Azure Resources]
```

**Virtual Network Manager Components:**
```mermaid
graph TB
    AVNM[Azure Virtual Network Manager] --> Connectivity[Connectivity Configuration]
    AVNM --> Security[Security Admin Rules]
    AVNM --> Routing[Routing Configuration]
    AVNM --> IPAM[IP Address Management]
    
    Connectivity --> HubSpoke[Hub-and-Spoke]
    Connectivity --> Mesh[Mesh Topology]
    
    Security --> AdminRules[Organization-Level Rules]
    Security --> NSGOverride[Override NSG Rules]
    
    Routing --> RouteTables[Centralized Route Tables]
    Routing --> RouteServer[Azure Route Server Integration]
    
    IPAM --> IPTracking[IP Space Tracking]
    IPAM --> Reachability[Reachability Verification]
```

**Learn more:**
- [Virtual Network Manager Features](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-network-manager)

## Hub-and-Spoke Architecture with Virtual Network Manager

### Traditional Hub-and-Spoke Challenges

In traditional hub-and-spoke implementations, you face several challenges:
- **Manual Configuration**: Each VNet peering must be configured individually
- **Inconsistency**: Different teams may configure peerings differently
- **Scalability**: Managing hundreds of VNets becomes complex
- **Maintenance**: Adding or removing spokes requires manual updates
- **Governance**: Difficult to enforce consistent network policies

### How Virtual Network Manager Solves This

Virtual Network Manager automates hub-and-spoke topology creation and maintenance:

```mermaid
graph TB
    subgraph "Virtual Network Manager"
        AVNM[Azure Virtual Network Manager<br/>Centralized Management]
        NG[Network Groups<br/>VNet Selection]
        CC[Connectivity Configuration<br/>Hub-and-Spoke]
        SAR[Security Admin Rules<br/>Organization Policies]
        RC[Routing Configuration<br/>Centralized Routes]
    end
    
    subgraph "Hub VNet (10.0.0.0/16)"
        Hub[Hub Virtual Network<br/>Shared Services]
        Firewall[Azure Firewall]
        VPNGW[VPN Gateway]
        Bastion[Azure Bastion]
    end
    
    subgraph "Spoke VNets"
        Spoke1[Spoke 1 VNet<br/>10.1.0.0/16<br/>Production]
        Spoke2[Spoke 2 VNet<br/>10.2.0.0/16<br/>Development]
        Spoke3[Spoke 3 VNet<br/>10.3.0.0/16<br/>Testing]
    end
    
    AVNM --> NG
    NG --> CC
    CC --> Hub
    CC --> Spoke1
    CC --> Spoke2
    CC --> Spoke3
    
    Hub --> Spoke1
    Hub --> Spoke2
    Hub --> Spoke3
    
    AVNM --> SAR
    SAR --> Hub
    SAR --> Spoke1
    SAR --> Spoke2
    SAR --> Spoke3
    
    AVNM --> RC
    RC --> Hub
    RC --> Spoke1
    RC --> Spoke2
    RC --> Spoke3
```

### Hub-and-Spoke Topology Benefits

**Centralized Services:**
- Shared security services (Azure Firewall, Network Virtual Appliances)
- Centralized connectivity (VPN Gateway, ExpressRoute Gateway)
- Shared management tools (Azure Bastion, Network Watcher)

**Isolation:**
- Each spoke is isolated from other spokes
- Spokes communicate only through the hub
- Prevents lateral movement between workloads

**Scalability:**
- Add new spokes without modifying existing ones
- Automatic peering configuration
- Consistent topology across all spokes

**Cost Optimization:**
- Share expensive resources (firewalls, gateways) in the hub
- Reduce redundant infrastructure
- Optimize network traffic routing

## Architecture Components

### 1. Network Manager Instance

The Network Manager instance is the top-level resource that defines the scope of management. During the creation process, you define the scope for what your Azure Virtual Network Manager instance, or _network manager_, manages. Your network manager only has the delegated access for resource visibility, configuration deployment, and IP address management within this scope boundary.

```mermaid
graph TB
    subgraph "Management Hierarchy"
        MG[Management Group]
        Sub1[Subscription 1]
        Sub2[Subscription 2]
        Sub3[Subscription 3]
    end
    
    AVNM[Network Manager Instance] --> Scope[Management Scope]
    Scope --> MG
    Scope --> Sub1
    Scope --> Sub2
    Scope --> Sub3
    
    AVNM --> Configs[Configurations]
    Configs --> CC[Connectivity Config]
    Configs --> SC[Security Admin Config]
    Configs --> RC[Routing Config]
    Configs --> IPAM[IP Address Management]
    
    AVNM --> DelegatedAccess[Delegated Access:<br/>- Resource Visibility<br/>- Configuration Deployment<br/>- IP Address Management]
```

**Scope Definition:**
- **Management Groups**: Apply to all subscriptions in a management group (provides hierarchical organization)
- **Subscriptions**: Apply to specific subscriptions directly
- **Scope Boundary**: Network manager only has access within the defined scope

**Network Manager Scope Hierarchy:**
```mermaid
graph TB
    subgraph "Management Group: Enterprise"
        MG[Management Group<br/>Enterprise]
        Sub1[Subscription 1<br/>Production]
        Sub2[Subscription 2<br/>Development]
        Sub3[Subscription 3<br/>Testing]
    end
    
    AVNM[Network Manager Instance] --> Scope[Scope Definition]
    Scope --> MG
    Scope --> Sub1
    Scope --> Sub2
    Scope --> Sub3
    
    AVNM --> Access[Delegated Access:<br/>- Resource Visibility<br/>- Configuration Deployment<br/>- IP Address Management]
    
    Access --> VNets1[VNets in Sub1]
    Access --> VNets2[VNets in Sub2]
    Access --> VNets3[VNets in Sub3]
```

**Important:** After you deploy the network manager, you create network groups, which serve as logical containers of networking resources to apply configurations at scale. Configurations do not take effect until they are deployed to regions containing your target network resources.

**Reference:** [How does Azure Virtual Network Manager work?](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview#how-does-azure-virtual-network-manager-work)

**Learn more:**
- [Create Network Manager Instance](https://learn.microsoft.com/en-us/azure/virtual-network-manager/create-virtual-network-manager-portal)
- [Network Manager Scope](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-network-manager-scope)

### 2. Network Groups

Network Groups define which VNets are included in configurations. A network group serves as a logical container of networking resources to apply configurations at scale.

**Selection Methods:**
- **Static Membership**: Manually select individual virtual networks to be added to your network group
- **Azure Policy**: Use Azure Policy to define conditions that govern your group membership dynamically
- **Dynamic Membership**: Automatically include VNets based on tags or conditions via Azure Policy initiatives

**Network Groups and Azure Policy:**
- Use Azure Policy initiatives to automatically add/remove VNets based on conditions
- Enforce consistent tagging for dynamic membership
- Scale network group membership as your infrastructure grows

**Network Group Membership Flow:**
```mermaid
flowchart TD
    Start[Create Network Group] --> Method{Membership Method?}
    Method -->|Static| Manual[Manually Select VNets]
    Method -->|Dynamic| Policy[Azure Policy Initiative]
    
    Manual --> Add[Add VNets to Group]
    Policy --> Conditions[Define Conditions:<br/>- Tags<br/>- Resource Type<br/>- Location]
    Conditions --> Auto[Auto-include Matching VNets]
    
    Add --> Group[Network Group]
    Auto --> Group
    
    Group --> Config[Apply Configurations]
    Config --> Deploy[Deploy to Regions]
```

**Network Group with Azure Policy:**
```mermaid
sequenceDiagram
    participant Admin as Administrator
    participant Policy as Azure Policy
    participant NG as Network Group
    participant VNet1 as VNet 1 (Tag: Environment=Prod)
    participant VNet2 as VNet 2 (Tag: Environment=Prod)
    participant VNet3 as VNet 3 (Tag: Environment=Dev)
    
    Admin->>Policy: Create Policy Initiative<br/>Tag = Environment:Production
    Admin->>NG: Create Network Group<br/>Dynamic Membership
    Admin->>NG: Assign Policy Initiative
    
    Policy->>VNet1: Evaluate: Tag Match?
    Policy->>VNet2: Evaluate: Tag Match?
    Policy->>VNet3: Evaluate: Tag Match?
    
    VNet1-->>NG: Auto-include (Match)
    VNet2-->>NG: Auto-include (Match)
    VNet3-->>NG: Exclude (No Match)
    
    NG->>NG: Apply Configurations<br/>to Group Members
```

**Reference:** [Network groups and Azure Policy](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-network-groups)

**Example Network Group:**
```mermaid
graph TD
    NG[Network Group: Production VNets]
    NG --> Static[Static: VNet-Prod-1]
    NG --> Static2[Static: VNet-Prod-2]
    NG --> Policy[Azure Policy: Tag = Environment:Production]
    Policy --> Auto1[Auto: VNet-Prod-3]
    Policy --> Auto2[Auto: VNet-Prod-4]
```

### 3. Connectivity Configuration

Connectivity configurations define how VNets connect to each other:

**Hub-and-Spoke Configuration:**
```mermaid
graph TB
    subgraph "Hub VNet"
        Hub[Hub VNet<br/>10.0.0.0/16]
    end
    
    subgraph "Spoke VNets"
        S1[Spoke 1<br/>10.1.0.0/16]
        S2[Spoke 2<br/>10.2.0.0/16]
        S3[Spoke 3<br/>10.3.0.0/16]
    end
    
    Hub -->|Peering| S1
    Hub -->|Peering| S2
    Hub -->|Peering| S3
    
    S1 -.->|No Direct Peering| S2
    S2 -.->|No Direct Peering| S3
    S1 -.->|No Direct Peering| S3
```

**Mesh Configuration:**
```mermaid
graph TB
    V1[VNet 1<br/>10.1.0.0/16]
    V2[VNet 2<br/>10.2.0.0/16]
    V3[VNet 3<br/>10.3.0.0/16]
    V4[VNet 4<br/>10.4.0.0/16]
    
    V1 <-->|Peering| V2
    V1 <-->|Peering| V3
    V1 <-->|Peering| V4
    V2 <-->|Peering| V3
    V2 <-->|Peering| V4
    V3 <-->|Peering| V4
```

**Key Features:**
- **Automatic Peering**: Creates and manages VNet peerings automatically
- **Gateway Transit**: Enable hub gateway for spoke-to-spoke communication
- **Topology Maintenance**: Automatically updates when VNets are added/removed
- **Simplified Hub-and-Spoke**: Enable direct connectivity between spoke virtual networks in a hub-and-spoke configuration without the complexity of managing a mesh network or manually configuring additional peerings

**Deployment:**
Once you create your desired network groups and configurations, you can deploy the configurations to any region of your choosing. **Configurations do not take effect until they are deployed to regions containing your target network resources.**

**Deployment Options:**
- Azure Portal
- Azure CLI
- Azure PowerShell
- Bicep
- Terraform

**Configuration Deployment Flow:**
```mermaid
sequenceDiagram
    participant Admin as Administrator
    participant AVNM as Network Manager
    participant Config as Configuration
    participant Region1 as Region 1: East US
    participant Region2 as Region 2: West Europe
    participant VNets as Target VNets
    
    Admin->>AVNM: Create Configurations<br/>(Connectivity, Security, Routing)
    Admin->>Config: Assign to Network Groups
    Config->>Config: Configuration Pending<br/>(Not Active)
    
    Admin->>AVNM: Deploy to Region 1
    AVNM->>Region1: Deploy Configuration
    Region1->>VNets: Apply Configuration<br/>Configuration Active
    
    Admin->>AVNM: Deploy to Region 2
    AVNM->>Region2: Deploy Configuration
    Region2->>VNets: Apply Configuration<br/>Configuration Active
```

**Regional Deployment Strategy:**
```mermaid
graph LR
    Config[Configuration Created] --> Pending[Pending State<br/>Not Active]
    Pending --> Deploy1[Deploy to Region 1]
    Deploy1 --> Active1[Active in Region 1]
    Pending --> Deploy2[Deploy to Region 2]
    Deploy2 --> Active2[Active in Region 2]
    Pending --> Deploy3[Deploy to Region 3]
    Deploy3 --> Active3[Active in Region 3]
    
    Active1 --> Rollback1[Rollback Available]
    Active2 --> Rollback2[Rollback Available]
    Active3 --> Rollback3[Rollback Available]
```

### 4. Security Admin Rules

Security Admin Rules provide organization-level security policies:

**Rule Evaluation Order:**
1. Security Admin Rules (highest priority)
2. Network Security Group (NSG) Rules
3. Default Azure rules

**Learn more:**
- [Security Admin Rules](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-security-admins)
- [Security Admin Rules vs NSG](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-security-admins#how-security-admin-rules-work)

```mermaid
flowchart TD
    Traffic[Incoming Traffic] --> SAR{Security Admin Rule?}
    SAR -->|Match| SARAction[Allow/Deny by Admin Rule]
    SAR -->|No Match| NSG{NSG Rule?}
    NSG -->|Match| NSGAction[Allow/Deny by NSG]
    NSG -->|No Match| Default[Default Azure Rules]
    
    SARAction --> Final[Final Decision]
    NSGAction --> Final
    Default --> Final
```

**Use Cases:**
- **Deny All Internet Traffic**: Organization-wide policy to block internet access
- **Allow Specific Services**: Permit access to approved Azure services only
- **Compliance Requirements**: Enforce regulatory compliance across all VNets
- **Emergency Response**: Quickly block or allow traffic during security incidents

### 5. Routing Configuration

A routing configuration lets you describe and orchestrate user-defined routes at scale to control traffic flow according to your desired routing behavior.

**Features:**
- **Route Tables**: Define and apply route tables to multiple VNets
- **Route Aggregation**: Combine routes from multiple sources
- **Integration**: Works with Azure Route Server and BGP
- **Centralized Management**: Apply consistent routing policies across all VNets in network groups

**Routing Configuration Architecture:**
```mermaid
graph TB
    RC[Routing Configuration] --> RouteTable[Centralized Route Table]
    RouteTable --> Routes[User-Defined Routes]
    
    Routes --> Route1[Route 1: 0.0.0.0/0 → Firewall]
    Routes --> Route2[Route 2: 10.0.0.0/8 → VPN Gateway]
    Routes --> Route3[Route 3: 192.168.0.0/16 → NVA]
    
    RC --> NG[Network Groups]
    NG --> VNet1[VNet 1]
    NG --> VNet2[VNet 2]
    NG --> VNet3[VNet 3]
    
    RouteTable --> VNet1
    RouteTable --> VNet2
    RouteTable --> VNet3
    
    RC --> RouteServer[Azure Route Server<br/>BGP Integration]
    RouteServer --> BGP[BGP Routes]
    BGP --> RouteTable
```

**Routing Flow:**
```mermaid
flowchart TD
    Packet[Packet Arrives] --> RouteTable[Check Route Table]
    RouteTable --> Match{Match Route?}
    Match -->|Yes| NextHop[Next Hop:<br/>Firewall, Gateway, NVA]
    Match -->|No| Default[Default Route]
    
    NextHop --> Firewall[Azure Firewall]
    NextHop --> VPNGW[VPN Gateway]
    NextHop --> NVA[Network Virtual Appliance]
    NextHop --> Internet[Internet Gateway]
    
    Default --> Internet
```

## Hub-and-Spoke Implementation Workflow

### Step 1: Create Network Manager Instance

1. Define the management scope (subscriptions, management groups)
2. Create the Network Manager instance
3. Assign appropriate permissions
4. Configure delegated access for resource visibility and configuration deployment

**Important:** The network manager only has access within the defined scope boundary.

### Step 2: Define Network Groups

1. Create network groups based on workload requirements
2. Define membership (static or dynamic via Azure Policy)
3. Tag VNets appropriately for dynamic membership
4. Use Azure Policy initiatives to automate membership

### Step 3: Configure Hub-and-Spoke Topology

1. Designate hub VNet(s)
2. Create connectivity configuration
3. Select network groups for spokes
4. Configure peering settings (gateway transit, etc.)
5. Choose between hub-and-spoke or mesh topology

### Step 4: Deploy Security Admin Rules

1. Define security policies
2. Create security admin rules
3. Assign to network groups
4. Test in staging before production
5. Document rule purposes and business justifications

### Step 5: Configure Routing

1. Define route tables
2. Create routing configuration
3. Apply to network groups
4. Validate routing paths
5. Integrate with Azure Route Server if needed

### Step 6: Deploy and Validate

1. **Deploy configurations to regions** - Configurations do not take effect until deployed
2. Choose deployment regions containing your target network resources
3. Validate connectivity using Network Watcher
4. Monitor with Azure Monitor
5. Use reachability verification to troubleshoot issues
6. Adjust as needed

**Deployment Strategy:**
- Roll out network changes through a specific region sequence and frequency of your choosing
- Enables controlled and safe network updates and rollbacks
- Deploy to non-production environments first

**Complete Workflow Diagram:**
```mermaid
flowchart TD
    Start[Start: Create Network Manager] --> Scope[Define Management Scope<br/>Subscriptions/Management Groups]
    Scope --> Create[Create Network Manager Instance]
    Create --> Groups[Create Network Groups<br/>Static or Dynamic via Policy]
    Groups --> Config[Create Configurations:<br/>Connectivity, Security, Routing]
    Config --> Deploy{Deploy to Regions}
    Deploy -->|Deploy| Regions[Deploy to Target Regions<br/>Configurations Take Effect]
    Regions --> Validate[Validate with Network Watcher]
    Validate --> Monitor[Monitor with Azure Monitor]
    Monitor --> Troubleshoot[Use Reachability Verification]
    Troubleshoot --> Adjust{Issues Found?}
    Adjust -->|Yes| Config
    Adjust -->|No| Complete[Deployment Complete]
```

## Comparison: Traditional vs. Virtual Network Manager

| Aspect | Traditional Hub-and-Spoke | Virtual Network Manager |
|--------|---------------------------|-------------------------|
| **Configuration** | Manual per-VNet | Automated, centralized |
| **Scalability** | Limited by manual effort | Scales to hundreds of VNets |
| **Consistency** | Varies by team | Enforced automatically |
| **Maintenance** | Manual updates required | Automatic topology maintenance |
| **Governance** | Difficult to enforce | Built-in policy enforcement |
| **Security** | Per-VNet NSG rules | Organization-level admin rules |
| **Time to Deploy** | Days/weeks | Minutes/hours |

## Integration with Other Azure Services

### Network Watcher Integration

```mermaid
graph LR
    AVNM[Virtual Network Manager] --> Topology[Creates Topology]
    Topology --> NW[Network Watcher]
    NW --> Monitor[Monitor Connectivity]
    NW --> Diagnose[Diagnose Issues]
    NW --> Validate[Validate Configurations]
```

- Network Watcher can monitor topologies created by Virtual Network Manager
- IP Flow Verify considers both NSG and Security Admin Rules
- Use Network Watcher to troubleshoot connectivity issues

### Azure Policy Integration

```mermaid
graph TB
    Policy[Azure Policy] --> NG[Network Groups]
    NG --> Auto[Auto-include VNets]
    Auto --> Config[Apply Configurations]
    Config --> VNets[VNets]
```

- Use Azure Policy to automatically include VNets in network groups
- Enforce tagging and compliance
- Dynamic membership based on policy conditions

### Azure Firewall Integration

```mermaid
graph TB
    AVNM[Virtual Network Manager] --> Hub[Hub VNet]
    Hub --> Firewall[Azure Firewall]
    AVNM --> SAR[Security Admin Rules]
    SAR --> Firewall
    Firewall --> Spokes[Spoke VNets]
```

- Centralize firewall management in hub
- Security Admin Rules can reference firewall policies
- Consistent security across all spokes

## Best Practices

### 1. Hub Design
- **Dedicated Hub VNet**: Use a separate VNet for hub services
- **Subnet Planning**: Plan subnets for firewall, gateways, shared services
- **Address Space**: Reserve sufficient IP space for growth
- **Redundancy**: Deploy hub services in multiple availability zones

### 2. Spoke Design
- **Isolation**: Keep spokes isolated from each other
- **Naming Convention**: Use consistent naming for easy management
- **Tagging**: Tag VNets for dynamic network group membership
- **Address Space**: Avoid overlapping IP ranges

### 3. Network Groups
- **Logical Grouping**: Group VNets by environment, workload, or team
- **Dynamic Membership**: Use Azure Policy for automatic inclusion
- **Documentation**: Document network group purposes and members

### 4. Security Admin Rules
- **Start Restrictive**: Begin with deny-all, then allow specific traffic
- **Test Thoroughly**: Test in staging before production deployment
- **Documentation**: Document rule purposes and business justifications
- **Review Regularly**: Periodically review and update rules

### 5. Deployment Strategy
- **Phased Rollout**: Deploy to non-production first
- **Validation**: Use Network Watcher to validate connectivity
- **Monitoring**: Set up alerts for configuration changes
- **Rollback Plan**: Have a plan to revert if issues occur

## Common Use Cases

### Enterprise Multi-Subscription Environment

```mermaid
graph TB
    subgraph "Management Group: Enterprise"
        AVNM[Virtual Network Manager]
        
        subgraph "Production Subscription"
            HubProd[Hub VNet Prod]
            Spoke1[Spoke 1: Web]
            Spoke2[Spoke 2: Database]
        end
        
        subgraph "Development Subscription"
            HubDev[Hub VNet Dev]
            Spoke3[Spoke 3: Dev Web]
            Spoke4[Spoke 4: Dev DB]
        end
        
        subgraph "Testing Subscription"
            HubTest[Hub VNet Test]
            Spoke5[Spoke 5: Test Web]
            Spoke6[Spoke 6: Test DB]
        end
    end
    
    AVNM --> HubProd
    AVNM --> HubDev
    AVNM --> HubTest
    AVNM --> Spoke1
    AVNM --> Spoke2
    AVNM --> Spoke3
    AVNM --> Spoke4
    AVNM --> Spoke5
    AVNM --> Spoke6
```

### Multi-Region Deployment

```mermaid
graph TB
    AVNM[Virtual Network Manager<br/>Global Scope]
    
    subgraph "Region 1: East US"
        Hub1[Hub VNet 1]
        Spoke1A[Spoke A]
        Spoke1B[Spoke B]
    end
    
    subgraph "Region 2: West Europe"
        Hub2[Hub VNet 2]
        Spoke2A[Spoke A]
        Spoke2B[Spoke B]
    end
    
    AVNM --> Hub1
    AVNM --> Hub2
    AVNM --> Spoke1A
    AVNM --> Spoke1B
    AVNM --> Spoke2A
    AVNM --> Spoke2B
    
    Hub1 <-->|Global Peering| Hub2
```

## Troubleshooting

### Common Issues

1. **Peering Not Created**
   - Verify network group membership
   - Check VNet address space conflicts
   - Validate permissions

2. **Security Admin Rules Blocking Traffic**
   - Review rule priority and order
   - Use Network Watcher IP Flow Verify
   - Check rule evaluation logs

3. **Routing Issues**
   - Verify route table configuration
   - Check for conflicting routes
   - Validate next hop configuration

### Diagnostic Tools

- **Network Watcher**: Topology, IP Flow Verify, Connection Troubleshoot
- **Azure Monitor**: Metrics and logs for Network Manager operations
- **Activity Log**: Track configuration changes and deployments

## Key Benefits

Based on the official Microsoft documentation, Azure Virtual Network Manager provides the following key benefits:

### Centralized Management
Manage connectivity and security policies globally across regions and subscriptions from a single pane of glass, reducing administrative overhead and ensuring consistency.

### Simplified Hub-and-Spoke Connectivity
Enable direct connectivity between spoke virtual networks in a hub-and-spoke configuration without the complexity of managing a mesh network or manually configuring additional peerings.

### Enterprise-Grade Reliability
Azure Virtual Network Manager is a highly scalable and highly available service with redundancy and replication across the globe.

### Advanced Security Controls
Create network security rules that are evaluated before network security group rules, providing granular control over traffic flow with global enforcement capabilities.

### Optimized Performance
Low latency and high bandwidth between resources in different virtual networks using virtual network peering.

### Flexible Deployment
Roll out network changes through a specific region sequence and frequency of your choosing for controlled and safe network updates and rollbacks.

### Cost Optimization
Reduce operational costs by automating network management tasks and eliminating the need for complex custom scripting solutions.

### Centralized IP Address Management
Manage your organization's IP address space by automatically allocating non-overlapping IP address space from IP address pools to prevent address space conflicts across on-premises and multicloud environments.

### Reachability Verification
Validate Azure network policies and troubleshoot connectivity issues by analyzing reachability paths between Azure resources and identifying Azure policies and configurations disallowing network traffic.

**Reference:** [Key Benefits](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview#key-benefits)

## Pricing and Availability

### Pricing Model
- **Virtual Network-Based Pricing**: New Azure Virtual Network Manager instances charge solely on the virtual network-based pricing
- **Subscription-Based Pricing**: Instances created before the release of virtual network-based pricing continue to charge on subscription-based pricing (to be retired February 6, 2028)

**Learn more:**
- [Azure Virtual Network Manager Pricing](https://learn.microsoft.com/en-us/azure/virtual-network-manager/pricing)
- [Switch Pricing Model](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview#pricing)

### Regions
For current information on the regions where Azure Virtual Network Manager is available, see:
- [Azure Virtual Network Manager Regions](https://learn.microsoft.com/en-us/azure/virtual-network-manager/regions)

### Limits
For detailed limits information, see:
- [Azure Virtual Network Manager Limits](https://learn.microsoft.com/en-us/azure/virtual-network-manager/limits)

### Service Level Agreement (SLA)
For SLA information, see:
- [SLA for Azure Virtual Network Manager](https://learn.microsoft.com/en-us/azure/virtual-network-manager/sla)

## Summary

Azure Virtual Network Manager revolutionizes network management in Azure by:
- **Automating** hub-and-spoke topology creation and maintenance
- **Centralizing** security and routing policies
- **Scaling** to hundreds of VNets across multiple subscriptions
- **Enforcing** consistent network governance
- **Reducing** operational overhead and human error
- **Managing** IP address space and preventing conflicts
- **Troubleshooting** connectivity with reachability verification

When combined with Network Watcher for monitoring and Azure Policy for governance, Virtual Network Manager provides a complete solution for enterprise-scale network management in Azure.

**Additional Resources:**
- [Virtual Network Manager Quickstart](https://learn.microsoft.com/en-us/azure/virtual-network-manager/quickstart-create-virtual-network-manager-portal)
- [Virtual Network Manager Tutorials](https://learn.microsoft.com/en-us/azure/virtual-network-manager/tutorial-create-secured-hub-and-spoke)
- [Virtual Network Manager Best Practices](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-network-manager)
- [Virtual Network Manager FAQ](https://learn.microsoft.com/en-us/azure/virtual-network-manager/faq)
- [Virtual Network Manager Use Cases](https://learn.microsoft.com/en-us/azure/virtual-network-manager/overview#use-cases)
- [Create Network Manager Instance](https://learn.microsoft.com/en-us/azure/virtual-network-manager/create-virtual-network-manager-portal)

