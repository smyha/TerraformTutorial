# FinOps Architecture Guide

This document visualizes the "Inform, Optimize, Operate" architecture implemented in this tutorial.

## The FinOps Lifecycle

The data must flow from the Foundation layer into Visibility tools, which then inform Optimization actions.

```mermaid
graph TD
    subgraph INFORM["Inform Phase (Visibility)"]
        Exports[Cost Exports]
        Budgets[Budget Alerts]
        Reports[PowerBI / Dashboards]
    end

    subgraph OPTIMIZE["Optimize Phase (Reduction)"]
        Sched[Resource Scheduler]
        Life[Storage Lifecycle]
        Orphan[Orphan Cleanup]
    end

    subgraph OPERATE["Operate Phase (Culture)"]
        Tags[Tagging Policy]
        K8s[K8s Showback]
        Process[Engineering Process]
    end

    Tags -->|Enables| Exports
    Exports -->|Feeds| Reports
    Reports -->|Identifies Waste| OPTIMIZE
    Budgets -->|Triggers| Process
```

## Module Interaction

How the Terraform modules work together in a production environment:

```mermaid
sequenceDiagram
    participant User
    participant Terraform
    participant Azure
    participant Slack

    User->>Terraform: Apply "Phase 1"
    Terraform->>Azure: Deploy Tagging Policy (Audit)
    Terraform->>Azure: Deploy Global Budget
    Terraform->>Azure: Enable Cost Export
    
    Note over Azure: Resources are created
    
    Azure->>Azure: Policy detects missing tags
    Azure->>Slack: Budget Alert (50% Reached)
    
    User->>Terraform: Apply "Phase 2"
    Terraform->>Azure: Update Policy (Deny)
    Terraform->>Azure: Deploy Resource Scheduler
    
    Note over Azure: New deployments MUST have tags
    Azure->>Azure: Scheduler stops Dev VMs at 7PM
```
