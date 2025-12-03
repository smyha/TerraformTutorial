# Terragrunt Architecture & Team Workflows

## Overview

This document explains the architecture of the Terragrunt setup and how teams collaborate using it.

---

## Architecture Diagram

```mermaid
graph TB
    subgraph "Repository Structure"
        Root[Repository Root]
        Root --> Live[live/]
        Root --> Modules[modules/]
        Root --> Examples[examples/]
    end
    
    subgraph "Live Environments"
        Live --> Stage[stage/]
        Live --> Prod[prod/]
        
        Stage --> StageRoot[terragrunt.hcl<br/>Backend: S3 Bucket A]
        Prod --> ProdRoot[terragrunt.hcl<br/>Backend: S3 Bucket B]
    end
    
    subgraph "Stage Components"
        StageRoot --> StageMySQL[data-stores/mysql]
        StageRoot --> StageApp[services/hello-world-app]
        StageMySQL --> StageMySQLState[State: stage/mysql/terraform.tfstate]
        StageApp --> StageAppState[State: stage/app/terraform.tfstate]
    end
    
    subgraph "Prod Components"
        ProdRoot --> ProdMySQL[data-stores/mysql]
        ProdRoot --> ProdApp[services/hello-world-app]
        ProdMySQL --> ProdMySQLState[State: prod/mysql/terraform.tfstate]
        ProdApp --> ProdAppState[State: prod/app/terraform.tfstate]
    end
    
    subgraph "Reusable Modules"
        Modules --> MySQLModule[modules/data-stores/mysql]
        Modules --> AppModule[modules/services/hello-world-app]
    end
    
    StageMySQL -.->|Uses| MySQLModule
    StageApp -.->|Uses| AppModule
    ProdMySQL -.->|Uses| MySQLModule
    ProdApp -.->|Uses| AppModule
    
    style StageRoot fill:#51cf66,color:#fff
    style ProdRoot fill:#ff6b6b,color:#fff
    style MySQLModule fill:#339af0,color:#fff
    style AppModule fill:#339af0,color:#fff
```

---

## State File Organization

### How State Files Are Organized

```mermaid
graph LR
    Bucket[S3 Bucket:<br/>terraform-state-bucket] --> StageDir[stage/]
    Bucket --> ProdDir[prod/]
    
    StageDir --> StageMySQLState[data-stores/mysql/<br/>terraform.tfstate]
    StageDir --> StageAppState[services/hello-world-app/<br/>terraform.tfstate]
    
    ProdDir --> ProdMySQLState[data-stores/mysql/<br/>terraform.tfstate]
    ProdDir --> ProdAppState[services/hello-world-app/<br/>terraform.tfstate]
    
    style Bucket fill:#51cf66,color:#fff
    style StageDir fill:#339af0,color:#fff
    style ProdDir fill:#ff6b6b,color:#fff
```

**Key Pattern:**

```hcl
# In root terragrunt.hcl
key = "${path_relative_to_include()}/terraform.tfstate"

# Results in unique keys:
# - stage/data-stores/mysql/terraform.tfstate
# - stage/services/hello-world-app/terraform.tfstate
# - prod/data-stores/mysql/terraform.tfstate
# - prod/services/hello-world-app/terraform.tfstate
```

---

## Dependency Flow

### How Dependencies Work

```mermaid
flowchart TD
    Start[terragrunt run-all apply] --> BuildGraph[Build dependency graph]
    BuildGraph --> MySQL[MySQL module<br/>No dependencies]
    BuildGraph --> App[App module<br/>Depends on MySQL]
    
    MySQL --> ApplyMySQL[Apply MySQL]
    ApplyMySQL --> MySQLOutputs[MySQL outputs:<br/>address, port]
    
    App --> WaitMySQL{Wait for<br/>MySQL?}
    WaitMySQL -->|Yes| CheckMySQL{MySQL<br/>complete?}
    CheckMySQL -->|No| Wait
    CheckMySQL -->|Yes| ReadOutputs[Read MySQL outputs]
    ReadOutputs --> ApplyApp[Apply App<br/>with MySQL outputs]
    ApplyApp --> Done[All modules deployed]
    
    style MySQL fill:#51cf66,color:#fff
    style App fill:#339af0,color:#fff
    style MySQLOutputs fill:#ffd93d,color:#000
    style Done fill:#51cf66,color:#fff
```

### Dependency Declaration

```hcl
# services/hello-world-app/terragrunt.hcl
dependency "mysql" {
  config_path = "../../data-stores/mysql"
  
  # Optional: Skip if dependency outputs are already available
  skip_outputs = false
  
  # Optional: Mock outputs for plan-only operations
  mock_outputs = {
    address = "mock-db-address"
    port    = 3306
  }
}
```

---

## Team Collaboration Patterns

### Pattern 1: Separate Environments

```mermaid
graph LR
    DevTeam[Dev Team] -->|Works on| DevEnv[dev/]
    StageTeam[Stage Team] -->|Works on| StageEnv[stage/]
    ProdTeam[Prod Team] -->|Works on| ProdEnv[prod/]
    
    DevEnv -->|Uses| SharedModules[Shared Modules]
    StageEnv -->|Uses| SharedModules
    ProdEnv -->|Uses| SharedModules
    
    style DevEnv fill:#339af0,color:#fff
    style StageEnv fill:#ffd93d,color:#000
    style ProdEnv fill:#ff6b6b,color:#fff
    style SharedModules fill:#51cf66,color:#fff
```

**Benefits:**
- Teams can work independently
- No state file conflicts
- Different backend buckets per environment
- Isolated deployments

### Pattern 2: Conflict Resolution

```mermaid
flowchart TD
    Original[Original config<br/>conflict-original/] --> Anna[Anna's changes<br/>conflict-anna/]
    Original --> Bill[Bill's changes<br/>conflict-bill/]
    
    Anna --> Merge[Merge changes]
    Bill --> Merge
    Merge --> Resolved[Resolved config]
    
    style Original fill:#51cf66,color:#fff
    style Anna fill:#339af0,color:#fff
    style Bill fill:#ff6b6b,color:#fff
    style Resolved fill:#51cf66,color:#fff
```

**Terragrunt helps with:**
- Isolated state files prevent conflicts
- Each developer can test in their own directory
- Easy to compare changes before merging

---

## Configuration Inheritance Flow

```mermaid
sequenceDiagram
    participant Root as Root terragrunt.hcl
    participant Child as Child terragrunt.hcl
    participant TG as Terragrunt
    participant TF as Terraform

    Note over Root: Defines remote_state
    Note over Child: Has include block
    
    Child->>TG: terragrunt apply
    TG->>Root: find_in_parent_folders()
    Root-->>TG: Return parent config
    TG->>TG: Merge configurations
    TG->>TG: Generate backend.tf
    TG->>TF: terraform init (with backend.tf)
    TF->>TF: Configure backend
    TF-->>TG: Ready to apply
```

**What gets inherited:**

1. **remote_state** configuration
2. **generate** blocks
3. Any other shared configuration

**What doesn't get inherited:**

1. **inputs** (each module has its own)
2. **dependency** blocks (module-specific)
3. **terraform { source }** (module-specific)

---

## Command Execution Flow

### Single Module Execution

```mermaid
flowchart TD
    Start[terragrunt apply] --> Read[Read terragrunt.hcl]
    Read --> Include[Include parent config]
    Include --> Dependencies{Has<br/>dependencies?}
    Dependencies -->|Yes| Resolve[Resolve dependencies]
    Dependencies -->|No| Generate
    Resolve --> ApplyDeps[Apply dependencies]
    ApplyDeps --> ReadDeps[Read dependency outputs]
    ReadDeps --> Generate[Generate backend.tf]
    Generate --> Prepare[Prepare inputs]
    Prepare --> Init[terraform init]
    Init --> Plan[terraform plan]
    Plan --> Apply[terraform apply]
    Apply --> End[Complete]
    
    style Start fill:#339af0,color:#fff
    style End fill:#51cf66,color:#fff
    style Resolve fill:#ffd93d,color:#000
    style Generate fill:#ffd93d,color:#000
```

### Run-All Execution

```mermaid
flowchart TD
    Start[terragrunt run-all apply] --> Scan[Scan directory tree]
    Scan --> Find[Find all terragrunt.hcl files]
    Find --> BuildGraph[Build dependency graph]
    BuildGraph --> TopoSort[Topological sort]
    TopoSort --> ApplyOrder[Apply in dependency order]
    ApplyOrder --> Module1[Apply module 1]
    Module1 --> Module2[Apply module 2]
    Module2 --> ModuleN[Apply module N]
    ModuleN --> End[All complete]
    
    style Start fill:#339af0,color:#fff
    style End fill:#51cf66,color:#fff
    style BuildGraph fill:#ffd93d,color:#000
    style TopoSort fill:#ffd93d,color:#000
```

---

## State File Isolation

### Why Isolation Matters

```mermaid
graph TB
    Team1[Team 1] -->|Works on| Module1[Module A]
    Team2[Team 2] -->|Works on| Module2[Module B]
    
    Module1 --> State1[State: module-a/terraform.tfstate]
    Module2 --> State2[State: module-b/terraform.tfstate]
    
    State1 --> Bucket[S3 Bucket]
    State2 --> Bucket
    
    Bucket --> Lock1[DynamoDB Lock: module-a]
    Bucket --> Lock2[DynamoDB Lock: module-b]
    
    style Module1 fill:#339af0,color:#fff
    style Module2 fill:#ff6b6b,color:#fff
    style State1 fill:#51cf66,color:#fff
    style State2 fill:#51cf66,color:#fff
```

**Benefits:**
- No state file conflicts
- Teams can work in parallel
- Easier to debug (isolated state)
- Safer rollbacks (affect only one module)

---

## Best Practices Summary

```mermaid
mindmap
  root((Terragrunt<br/>Best Practices))
    Structure
      Separate environments
      Clear module boundaries
      Consistent naming
    State Management
      Unique state keys
      Isolated state files
      Proper locking
    Dependencies
      Use dependency blocks
      Avoid circular deps
      Document dependencies
    Configuration
      DRY principles
      Environment variables
      Sensitive data handling
    Team Workflow
      Code reviews
      Testing strategy
      Conflict resolution
```

---

## Common Patterns

### Pattern 1: Environment-Specific Configuration

```hcl
# live/stage/terragrunt.hcl
remote_state {
  config = {
    bucket = "terraform-state-stage"
    # ...
  }
}

# live/prod/terragrunt.hcl
remote_state {
  config = {
    bucket = "terraform-state-prod"
    # ...
  }
}
```

### Pattern 2: Shared Module, Different Inputs

```hcl
# stage/services/hello-world-app/terragrunt.hcl
inputs = {
  environment = "stage"
  min_size    = 2
  max_size    = 2
}

# prod/services/hello-world-app/terragrunt.hcl
inputs = {
  environment = "prod"
  min_size    = 4
  max_size    = 10
}
```

### Pattern 3: Conditional Dependencies

```hcl
# Only include dependency in certain environments
dependency "monitoring" {
  config_path = "../../monitoring"
  skip_outputs = get_env("SKIP_MONITORING", "false") == "true"
}
```

---

## Troubleshooting Guide

### Issue: "Could not find parent terragrunt.hcl"

**Solution:** Ensure parent file exists and `find_in_parent_folders()` can reach it.

```mermaid
flowchart TD
    Error[Error: Could not find parent] --> Check[Check directory structure]
    Check --> Exists{Parent file<br/>exists?}
    Exists -->|No| Create[Create parent terragrunt.hcl]
    Exists -->|Yes| CheckPath[Check path calculation]
    CheckPath --> Fix[Fix include path]
    
    style Error fill:#ff6b6b,color:#fff
    style Create fill:#51cf66,color:#fff
    style Fix fill:#51cf66,color:#fff
```

### Issue: "Dependency outputs not available"

**Solution:** Ensure dependency is applied first or use `mock_outputs` for planning.

```hcl
dependency "mysql" {
  config_path = "../../data-stores/mysql"
  mock_outputs = {
    address = "mock-address"
    port    = 3306
  }
}
```

### Issue: "State file conflicts"

**Solution:** Ensure unique state keys using `path_relative_to_include()`.

```hcl
key = "${path_relative_to_include()}/terraform.tfstate"
```

---

## Summary

Terragrunt provides a powerful way to:

1. **Organize** infrastructure code across environments
2. **Manage** dependencies automatically
3. **Standardize** backend configuration
4. **Enable** team collaboration
5. **Simplify** complex deployments

The key is understanding how configuration inheritance, dependency management, and state file organization work together to create a maintainable infrastructure codebase.

