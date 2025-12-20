# Azure FinOps Modular Architecture with Terraform

This tutorial implements a comprehensive **Azure FinOps** architecture using Terraform. It provides a library of specialized modules categorized by their function in the FinOps lifecycle (Inform, Optimize, Operate), enabling you to implement financial governance, observability, and cost optimization at scale.

## 🎯 Quick Start

```hcl
# Phase 1: Foundation - Start with visibility
module "cost_export" {
  source = "./modules/finops-cost-export"
  resource_group_id = "/subscriptions/.../resourceGroups/rg-finops"
  location = "eastus"
  storage_account_name = "stfinopsexport001"
}

module "tagging_policy" {
  source = "./modules/finops-tagging-policy"
  subscription_id = "/subscriptions/..."
  policy_effect = "Audit"  # Start with Audit, then switch to Deny
}
```

See [examples/phase1-visibility/main.tf](./examples/phase1-visibility/main.tf) for a complete example.

## 📚 Table of Contents

- [Overview](#overview)
- [FinOps Architecture](#finops-architecture)
- [Directory Structure](#directory-structure)
- [Modules](#modules)
- [Implementation Roadmap](#implementation-roadmap)
- [Getting Started](#getting-started)

## Overview

Cloud FinOps is an operational framework and cultural practice that maximizes the business value of cloud, enables timely data-driven decision making, and creates financial accountability through collaboration between engineering, finance, and business teams.

This codebase provides the technical building blocks (Terraform modules) to implement this framework on Azure.

## FinOps Architecture

Our architecture is divided into specialized layers corresponding to the FinOps phases:

### 1. Foundation & Governance (Inform Phase)
Foundational guardrails that ensure costs can be tracked and attributed. Without this, cost optimization is impossible.
- **Tagging Policies**: Enforce ownership and cost center attribution.
- **Budget Guardrails**: Decentralize accountability with automated budgets.

### 2. Data Observability (Inform Phase)
Ensuring transparency and accessibility of billing data.
- **Cost Exports**: Automated export of granular billing data for analysis.

### 3. Automated Optimization (Optimize Phase)
Active reduction of waste ("Wastage") through automation.
- **Resource Scheduler**: Automatically stop non-production resources off-hours.
- **Storage Lifecycle**: Move cold data to cheaper storage tiers.
- **Orphan Cleanup**: Detect and remove unused resources (unattached disks, IPs).

### 4. Specialized Workloads (Operate Phase)
Deep visibility into complex compute environments.
- **Container Cost Allocation**: Showback for shared Kubernetes clusters.

## Directory Structure

```
azure-finops/
├── modules/                        # Reusable Terraform modules
│   ├── finops-tagging-policy/      # Governance: Tag enforcement
│   ├── finops-budget-guardrails/   # Governance: Automated budgets
│   ├── finops-cost-export/         # Observability: Billing data export
│   ├── finops-resource-scheduler/  # Optimization: Auto-shutdown/start
│   ├── finops-storage-lifecycle/   # Optimization: Data usage optimization
│   ├── finops-orphan-cleanup/      # Optimization: Waste removal
│   └── k8s-cost-agent/             # Specialized: Kubernetes visibility
├── examples/                       # Implementation Phases
│   ├── phase1-visibility/          # Day 1: Foundation (Inform)
│   ├── phase2-hygiene/             # Day 90: Optimization (Optimize)
│   └── phase3-optimization/        # Day 150+: Operation (Operate)
└── docs/                           # Detailed Documentation
    └── FINOPS_ARCHITECTURE_GUIDE.md
```

## Modules

### Foundation & Governance (Inform Phase)

#### `finops-tagging-policy`
**Goal**: Implement "Guardrails" to prevent or audit deployments without mandatory tags (e.g., `CostCenter`, `Owner`, `Environment`).  
**Technical**: Uses Azure Policy (Audit, Deny, or Modify effects).  
**Features**: Multiple required tags, tag value validation, subscription/management group/resource group scope.  
**📖 [Documentation](./modules/finops-tagging-policy/README.md)**

#### `finops-budget-guardrails`
**Goal**: Automate budget creation and alerting.  
**Technical**: Deploys budgets to subscriptions/resource groups with Action Groups for Email/SMS/Webhook notifications at configurable thresholds (default: 50%, 80%, 100%).  
**Features**: Multi-scope support, forecasted alerts, multiple notification channels, integration with centralized Action Group modules.  
**📖 [Documentation](./modules/finops-budget-guardrails/README.md)**

### Data Observability (Inform Phase)

#### `finops-cost-export`
**Goal**: Periodic export of detailed billing data.  
**Technical**: Configures Cost Management Exports to Azure Storage (supports Parquet/CSV).  
**Features**: Daily/Weekly/Monthly exports, multiple query types, integration with centralized Storage Account modules.  
**📖 [Documentation](./modules/finops-cost-export/README.md)**

### Automated Optimization (Optimize Phase)

#### `finops-resource-scheduler`
**Goal**: Stop "bleeding" money on non-prod resources during nights/weekends.  
**Technical**: Automation Account & Runbooks to stop/start VMs based on tags and schedules.  
**Features**: Tag-based selection, configurable schedules, start/stop runbooks, integration with centralized Automation Account modules.  
**Savings**: ~70% on Dev environments (168h vs 50h/week).  
**📖 [Documentation](./modules/finops-resource-scheduler/README.md)**

#### `finops-storage-lifecycle`
**Goal**: Move cold data to Archive tiers automatically.  
**Technical**: Storage Management Policies for automatic tiering (Hot → Cool → Archive).  
**Features**: Multiple rules, prefix matching, snapshot/version management, integration with centralized Storage Account modules.  
**Savings**: 50-90% reduction in storage costs for cold data.  
**📖 [Documentation](./modules/finops-storage-lifecycle/README.md)**

#### `finops-orphan-cleanup`
**Goal**: Detect and delete unused resources.  
**Technical**: Azure Resource Graph queries to identify orphaned resources (unattached disks, unused IPs, etc.).  
**Features**: Multiple query types, customizable KQL queries, export for automation scripts.  
**📖 [Documentation](./modules/finops-orphan-cleanup/README.md)**

### Specialized Workloads (Operate Phase)

#### `k8s-cost-agent`
**Goal**: Visibility into K8s clusters for cost allocation.  
**Technical**: Deploys Kubecost extension or enables native Azure cost analysis.  
**Features**: Pod-level cost visibility, namespace allocation, label-based attribution.  
**📖 [Documentation](./modules/k8s-cost-agent/README.md)**

## Implementation Roadmap

### Phase 1: Visibility & Foundation (Day 1-60)
**Focus**: *Inform* - "See where the money goes."
- Deploy **Cost Export** to start building history.
- Apply **Tagging Policy** in **AUDIT** mode to identify offenders without blocking work.
- Set **Global Budgets** to catch massive anomalies.

### Phase 2: Hygiene & Control (Day 61-120)
**Focus**: *Optimize* - "Quick Wins."
- Switch **Tagging Policy** to **DENY** for new resources.
- Deploy **Resource Scheduler** for Dev/Sandbox environments (saving ~60% compute).
- Run **Orphan Cleanup** in report mode.

### Phase 3: continuous Optimization (Day 121+)
**Focus**: *Operate* - "Continuous Improvement."
- Automate **Orphan Cleanup** deletion.
- Refine budgets to Team/Service level.
- Integrate cost metrics into engineering dashboards.

## Getting Started

### Prerequisites

- Terraform >= 1.0
- Azure Provider >= 3.0
- Azure CLI configured with appropriate permissions
- Azure Subscription with Contributor or Owner role

### Step 1: Clone and Navigate

```bash
cd azure-finops
```

### Step 2: Select Your Phase

Start with **Phase 1** to build your foundation:

```bash
cd examples/phase1-visibility
terraform init
terraform plan
terraform apply
```

### Step 3: Review Documentation

- **Architecture Guide**: See [docs/FINOPS_ARCHITECTURE_GUIDE.md](./docs/FINOPS_ARCHITECTURE_GUIDE.md) for deep dives
- **User Guide**: See [docs/USER_GUIDE.md](./docs/USER_GUIDE.md) for operational guidance
- **Module Documentation**: Each module has a detailed README with examples

## Module Integration Patterns

All modules support integration with centralized infrastructure modules:

### Using Storage Accounts from Modules

```hcl
module "shared_storage" {
  source = "git::https://github.com/org/terraform-azurerm-storage-account.git"
  # ... configuration
}

module "cost_export" {
  source = "./modules/finops-cost-export"
  create_storage_account = false
  existing_storage_account_id = module.shared_storage.storage_account_id
  # ...
}
```

### Using Action Groups from Modules

```hcl
module "shared_monitor" {
  source = "git::https://github.com/org/terraform-azurerm-monitor.git"
  # ... configuration
}

module "budget" {
  source = "./modules/finops-budget-guardrails"
  create_action_group = false
  existing_action_group_id = module.shared_monitor.action_group_id
  # ...
}
```

See each module's README for detailed integration examples.

## Cost Savings Examples

| Module | Typical Savings | Use Case |
|--------|----------------|----------|
| `finops-resource-scheduler` | 60-70% | Dev/Test VMs running 24/7 |
| `finops-storage-lifecycle` | 50-90% | Cold data in Hot tier |
| `finops-orphan-cleanup` | 5-15% | Unattached disks, unused IPs |
| `finops-tagging-policy` | Enables all other optimizations | Cost allocation foundation |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Contributing

This is an educational tutorial. For production use, consider:
- Adding comprehensive tests
- Implementing proper state management
- Adding CI/CD pipelines
- Implementing proper secrets management
- Adding monitoring and alerting

## License

This tutorial is provided as-is for educational purposes.
