# Troubleshoot a network by using Network Watcher monitoring and diagnostic toolss

## What is Network Watcher?

Azure Network Watcher is a centralized service for monitoring and diagnosing the health of Azure networks. It provides tools grouped into three categories:
- **Monitoring tools**
- **Network diagnostic tools**
- **Traffic logging tools**

Network Watcher helps identify issues like connectivity problems, latency, packet drops, and misconfigured security rules.

**Network Watcher Overview:**
```mermaid
graph TB
    NW[Network Watcher<br/>Centralized Service] --> Monitor[Monitoring Tools]
    NW --> Diagnose[Diagnostic Tools]
    NW --> Logging[Traffic Logging]
    
    Monitor --> Topology[Topology]
    Monitor --> ConnMonitor[Connection Monitor]
    Monitor --> NPM[Network Performance Monitor]
    
    Diagnose --> IPFlow[IP Flow Verify]
    Diagnose --> NSGDiag[NSG Diagnostics]
    Diagnose --> NextHop[Next Hop]
    Diagnose --> PacketCapture[Packet Capture]
    
    Logging --> NSGLogs[NSG Flow Logs]
    Logging --> VNetLogs[VNet Flow Logs]
    Logging --> TrafficAnalytics[Traffic Analytics]
```

**Learn more:**
- [Network Watcher Overview](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview)
- [Network Watcher Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/)

Azure Network Watcher includes several tools you can use to monitor your virtual networks and virtual machines (VMs). To effectively make use of Network Watcher, it's essential to understand all the available options and the purpose of each tool.

In your engineering company, you want to help your staff to choose the right Network Watcher tool for each troubleshooting task. They need to understand all the options available and the kinds of problems that each tool can solve.

Here, you look at the Network Watcher tool categories, the tools in each category, and how each tool is applied in example use cases.

## **Tool Categories and Details**

### **Monitoring Tools**
1. **Topology**
   - Visualizes the Azure virtual network, resources, and interconnections.
   - Useful for understanding infrastructure before troubleshooting.

2. **Connection Monitor**
   - Verifies connectivity between Azure resources.
   - Measures latency and detects configuration changes or NSG rule impacts.
   - Can monitor IP addresses or FQDNs.

**Connection Monitor Flow:**
```mermaid
sequenceDiagram
    participant CM as Connection Monitor
    participant Source as Source Resource
    participant Dest as Destination Resource
    participant NSG as NSG Rules
    
    CM->>Source: Test Connection
    Source->>NSG: Check Rules
    NSG->>Source: Allow/Deny
    Source->>Dest: Send Packet
    Dest->>Source: Response
    Source->>CM: Latency & Status
    CM->>CM: Record Metrics
```

**Learn more:**
- [Connection Monitor](https://learn.microsoft.com/en-us/azure/network-watcher/connection-monitor-overview)

3. **Network Performance Monitor**
   - Tracks latency and packet drops over time.
   - Monitors hybrid connections, ExpressRoute circuits, and endpoint-to-endpoint connectivity.

### **Network Diagnostic Tools**
1. **IP Flow Verify**
   - Checks if packets are allowed or denied for a VM.
   - Identifies NSG blocking rules using 5-tuple parameters.

**IP Flow Verify Process:**
```mermaid
flowchart TD
    Start[IP Flow Verify Request] --> Extract[Extract 5-Tuple:<br/>Source IP, Source Port,<br/>Dest IP, Dest Port, Protocol]
    Extract --> CheckNSG{Check NSG Rules}
    CheckNSG -->|Match Allow| Allow[Allow Traffic]
    CheckNSG -->|Match Deny| Deny[Deny Traffic<br/>Show Blocking Rule]
    CheckNSG -->|No Match| Default[Default Rules]
    Default --> Result[Return Result]
    Allow --> Result
    Deny --> Result
```

**Learn more:**
- [IP Flow Verify](https://learn.microsoft.com/en-us/azure/network-watcher/diagnose-vm-network-traffic-filtering-problem)

2. **NSG Diagnostics**
   - Displays NSGs traversed and rules applied for a source-destination pair.
   - Shows final allow/deny status.

3. **Next Hop**
   - Determines packet routing path from a VM to a destination.
   - Diagnoses routing table issues.

**Next Hop Analysis:**
```mermaid
graph LR
    VM[Source VM] --> NextHop[Next Hop Tool]
    NextHop --> RouteTable[Check Route Table]
    RouteTable --> Result{Next Hop Type}
    Result -->|VNet| VNet[Virtual Network]
    Result -->|Internet| Internet[Internet Gateway]
    Result -->|None| Drop[No Route - Drop]
    Result -->|VirtualAppliance| NVA[Network Virtual Appliance]
    Result -->|ServiceEndpoint| Endpoint[Service Endpoint]
```

**Learn more:**
- [Next Hop](https://learn.microsoft.com/en-us/azure/network-watcher/diagnose-vm-network-routing-problem)

4. **Effective Security Rules**
   - Lists all effective NSG rules applied to a network interface.
   - Helps identify blocking rules and unnecessary open ports.

5. **Packet Capture**
   - Captures packets for detailed analysis.
   - Useful for diagnosing low-level network issues.

**Packet Capture Architecture:**
```mermaid
graph TB
    NW[Network Watcher] --> Agent[Network Watcher Agent<br/>VM Extension]
    Agent --> VM[Target VM]
    VM --> Capture[Capture Packets]
    Capture --> Storage[Storage Account<br/>.cap files]
    Storage --> Analysis[Analysis Tools<br/>Wireshark, tcpdump]
```

**Learn more:**
- [Packet Capture](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-packet-capture-manage-portal)

6. **Connection Troubleshoot**
   - Tests connectivity between resources and provides remediation steps.

7. **VPN Troubleshoot**
   - Diagnoses VPN gateway and connection issues.

**Network Watcher Tool Categories**
```mermaid
graph TD
    A[Network Watcher] --> B[Monitoring Tools]
    A --> C[Diagnostic Tools]
    A --> D[Traffic Logging]
    B --> B1[Topology]
    B --> B2[Connection Monitor]
    B --> B3[Network Performance Monitor]
    C --> C1[IP Flow Verify]
    C --> C2[NSG Diagnostics]
    C --> C3[Next Hop]
    C --> C4[Effective Security Rules]
    C --> C5[Packet Capture]
    C --> C6[Connection Troubleshoot]
    C --> C7[VPN Troubleshoot]
```

**Troubleshooting Workflow**
```mermaid
flowchart LR
    Start{Network Issue Detected} --> Topology[Visualize Network Topology]
    Topology --> ConnectionMonitor[Check Connectivity]
    ConnectionMonitor --> IPFlow[Verify IP Flow]
    IPFlow --> NSGDiag[Analyze NSG Rules]
    NSGDiag --> NextHop[Check Routing]
    NextHop --> PacketCapture[Capture Packets if Needed]
    PacketCapture --> Resolve[Apply Fixes and Validate]
```

#### Quick Comparison: Network Watcher vs. Virtual Network Manager

| Aspect       | Network Watcher                       | Virtual Network Manager                                |
| ------------ | ------------------------------------- | ------------------------------------------------------ |
| Purpose      | Monitoring and troubleshooting        | Centralized governance and configuration               |
| Scope        | Regional                              | Multi-subscription and multi-region                    |
| Key Features | Topology, diagnostics, packet capture | Connectivity (mesh/hub), security admin rules, routing |
| Use Case     | Operational support                   | Design and enforce network standards                   |

**Integration:**
- Network Watcher can monitor and validate configurations created by Virtual Network Manager
- IP Flow Verify considers both NSG rules and Virtual Network Manager security admin rules
- Use Network Watcher to troubleshoot issues in topologies managed by Virtual Network Manager

---

#### Practical Tips
- Use **Virtual Network Manager** for consistent topology and security policies across large environments.
- Use **Network Watcher** for real-time diagnostics and troubleshooting.
- Combine with **Azure Monitor** for alerts and analytics.

## Module assessment

Question 1: To capture traffic on a virtual machine (VM), Azure Network Watcher requires:

- ✅ Correct: Network Watcher Agent VM Extension

Why:

- To perform packet capture on a VM, Network Watcher needs the Network Watcher Agent VM Extension installed on that VM. This extension enables capturing and sending traffic data to storage for analysis.

- ❌ Not correct: Azure Traffic Manager
    
    Why not:

  - Traffic Manager is a DNS-based global load balancer, not a diagnostic tool. It does not capture traffic or interact with VM-level packet data.

- ❌ Not correct: An Azure storage account

    Why not:
  
  - While a storage account is used to store captured packets, it is not the requirement to enable capture. The essential prerequisite is the VM extension. The storage account is a destination, not the enabling component.

Question 2: To resolve latency issues on the network, which Azure Network Watcher features can you use?

- ✅ Correct: Connection troubleshoot

Why:

- Connection Troubleshoot tests connectivity between two endpoints (VMs, IPs, FQDNs) and provides hop-by-hop latency and packet loss details, making it the right tool for diagnosing latency problems.

- ❌ Not correct: IP flow verify

    Why not:

    - IP Flow Verify checks whether traffic is allowed or denied by NSGs and rules. It does not measure latency; it only validates access control.

- ❌ Not correct: Next hop

    Why not:
    
    - Next Hop shows the routing path for a packet (which route or gateway will be used). It helps with routing issues but does not provide latency metrics.

