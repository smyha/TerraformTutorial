# Terragrunt Tutorial: Working with Teams

## Table of Contents

1. [What is Terragrunt?](#what-is-terragrunt)
2. [Key Concepts](#key-concepts)
3. [Terragrunt Flow Diagram](#terragrunt-flow-diagram)
4. [Configuration Blocks Explained](#configuration-blocks-explained)
5. [Common Commands](#common-commands)
6. [Best Practices](#best-practices)

---

## What is Terragrunt?

Terragrunt is a thin wrapper around Terraform that provides:

- **DRY (Don't Repeat Yourself)**: Eliminate code duplication across environments
- **Automatic Backend Configuration**: Generate backend.tf files automatically
- **Dependency Management**: Automatically handle module dependencies
- **Remote State Management**: Simplify remote state configuration
- **Team Collaboration**: Standardize workflows across teams

```mermaid
graph TB
    A[Developer] -->|Writes| B[terragrunt.hcl]
    B -->|Terragrunt reads| C[Parent terragrunt.hcl]
    C -->|Generates| D[backend.tf]
    B -->|Resolves| E[Dependencies]
    E -->|Waits for| F[Upstream modules]
    B -->|Calls| G[Terraform]
    G -->|Uses| D
    G -->|Applies| H[Infrastructure]
    
    style B fill:#339af0,color:#fff
    style C fill:#51cf66,color:#fff
    style D fill:#ffd93d,color:#000
    style G fill:#ff6b6b,color:#fff
```

---

## Key Concepts

### 1. Include Block

The `include` block allows child configurations to inherit settings from parent configurations.

```mermaid
flowchart TD
    Root[Root terragrunt.hcl<br/>live/stage/terragrunt.hcl] -->|find_in_parent_folders| Child1[Child terragrunt.hcl<br/>services/hello-world-app]
    Root -->|find_in_parent_folders| Child2[Child terragrunt.hcl<br/>data-stores/mysql]
    
    Root -.->|Inherits| RemoteState[remote_state config]
    Child1 -.->|Gets| RemoteState
    Child2 -.->|Gets| RemoteState
    
    style Root fill:#51cf66,color:#fff
    style Child1 fill:#339af0,color:#fff
    style Child2 fill:#339af0,color:#fff
```

**Example:**

```hcl
# live/stage/terragrunt.hcl (Parent)
remote_state {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    # ...
  }
}

# live/stage/services/hello-world-app/terragrunt.hcl (Child)
include {
  path = find_in_parent_folders()  # Finds live/stage/terragrunt.hcl
}

# Child automatically inherits remote_state config!
```

### 2. Remote State Block

Configures where Terraform state files are stored. Terragrunt automatically generates `backend.tf` files.

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant TG as Terragrunt
    participant Parent as Parent terragrunt.hcl
    participant Child as Child terragrunt.hcl
    participant FS as File System
    participant TF as Terraform

    Dev->>TG: terragrunt apply
    TG->>Parent: Read remote_state block
    TG->>Child: Include parent config
    TG->>FS: Generate backend.tf
    FS-->>TG: backend.tf created
    TG->>TF: terraform init (uses backend.tf)
    TF->>TF: Configure S3 backend
```

**Example:**

```hcl
remote_state {
  backend = "s3"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  
  config = {
    bucket         = get_env("STATE_BUCKET", "my-bucket")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Generated backend.tf:**

```hcl
terraform {
  backend "s3" {
    bucket         = "my-bucket"
    key            = "services/hello-world-app/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 3. Generate Block

Automatically creates Terraform configuration files.

```mermaid
graph LR
    A[Terragrunt reads<br/>generate block] --> B[Creates file<br/>at specified path]
    B --> C[backend.tf<br/>or provider.tf]
    C --> D[Terraform uses<br/>generated file]
    
    style A fill:#339af0,color:#fff
    style B fill:#51cf66,color:#fff
    style C fill:#ffd93d,color:#000
```

**Common use cases:**

- `backend.tf`: Backend configuration
- `provider.tf`: Provider version constraints
- `versions.tf`: Terraform version requirements

### 4. Dependency Block

Manages dependencies between modules automatically.

```mermaid
flowchart TD
    A[Module A: MySQL] -->|dependency block| B[Module B: App]
    B -->|Waits for| A
    A -->|Applies first| C[MySQL deployed]
    C -->|Outputs available| D[App can read outputs]
    D -->|Applies second| E[App deployed]
    
    style A fill:#51cf66,color:#fff
    style B fill:#339af0,color:#fff
    style C fill:#ffd93d,color:#000
    style E fill:#ffd93d,color:#000
```

**Example:**

```hcl
# live/stage/services/hello-world-app/terragrunt.hcl
dependency "mysql" {
  config_path = "../../data-stores/mysql"
}

inputs = {
  mysql_config = dependency.mysql.outputs  # Auto-populated!
}
```

**What happens:**

1. Terragrunt detects the dependency
2. Runs `terragrunt apply` on MySQL first
3. Waits for MySQL to complete
4. Reads MySQL outputs
5. Makes them available as `dependency.mysql.outputs`
6. Then runs `terragrunt apply` on the app

### 5. Inputs Block

Passes variables to Terraform modules (equivalent to `-var` flags).

```mermaid
graph LR
    A[terragrunt.hcl<br/>inputs block] -->|Maps to| B[Terraform module<br/>variables]
    B -->|Used in| C[Module resources]
    
    style A fill:#339af0,color:#fff
    style B fill:#51cf66,color:#fff
```

**Example:**

```hcl
inputs = {
  environment      = "stage"
  ami              = "ami-0fb653ca2d3203ac1"
  min_size         = 2
  max_size         = 2
  enable_autoscaling = false
  mysql_config     = dependency.mysql.outputs
}
```

---

## Terragrunt Flow Diagram

```mermaid
flowchart TD
    Start[Developer runs<br/>terragrunt apply] --> Read[Read terragrunt.hcl]
    Read --> Include{Has include<br/>block?}
    Include -->|Yes| FindParent[find_in_parent_folders]
    FindParent --> Merge[Merge parent config]
    Include -->|No| CheckDeps
    Merge --> CheckDeps{Has dependency<br/>blocks?}
    CheckDeps -->|Yes| ResolveDeps[Resolve dependencies]
    ResolveDeps --> ApplyDeps[Apply dependencies first]
    ApplyDeps --> ReadOutputs[Read dependency outputs]
    CheckDeps -->|No| GenerateBackend
    ReadOutputs --> GenerateBackend[Generate backend.tf]
    GenerateBackend --> PrepareInputs[Prepare inputs from<br/>inputs block + dependencies]
    PrepareInputs --> CallTerraform[Call terraform init/plan/apply]
    CallTerraform --> End[Infrastructure deployed]
    
    style Start fill:#339af0,color:#fff
    style End fill:#51cf66,color:#fff
    style ResolveDeps fill:#ffd93d,color:#000
    style GenerateBackend fill:#ffd93d,color:#000
```

---

## Configuration Blocks Explained

### Complete Example Structure

```mermaid
graph TB
    Root[Root: live/stage/terragrunt.hcl]
    Root -->|Contains| RemoteState[remote_state block]
    
    MySQL[MySQL: data-stores/mysql/terragrunt.hcl]
    MySQL -->|Has| Include1[include block]
    MySQL -->|Has| Source1[terraform source]
    MySQL -->|Has| Inputs1[inputs block]
    
    App[App: services/hello-world-app/terragrunt.hcl]
    App -->|Has| Include2[include block]
    App -->|Has| Source2[terraform source]
    App -->|Has| Dependency[dependency mysql]
    App -->|Has| Inputs2[inputs block]
    
    Include1 -.->|Finds| Root
    Include2 -.->|Finds| Root
    Dependency -.->|Points to| MySQL
    
    style Root fill:#51cf66,color:#fff
    style MySQL fill:#339af0,color:#fff
    style App fill:#ff6b6b,color:#fff
```

### Block Reference Table

| Block | Purpose | Required | Example |
|-------|---------|----------|---------|
| `terraform { source }` | Points to Terraform module | Yes | `source = "../../modules/mysql"` |
| `include` | Inherit parent config | Usually | `path = find_in_parent_folders()` |
| `remote_state` | Backend configuration | In parent | S3/DynamoDB settings |
| `generate` | Auto-generate files | Optional | Create `backend.tf` |
| `dependency` | Module dependencies | Optional | Wait for MySQL before app |
| `inputs` | Module variables | Optional | Pass values to module |

---

## Common Commands

### Basic Commands

```bash
# Apply a single module
terragrunt apply

# Plan changes
terragrunt plan

# Destroy infrastructure
terragrunt destroy

# Show current state
terragrunt output

# Validate configuration
terragrunt validate
```

### Working with Multiple Modules

```bash
# Apply all modules in dependency order
terragrunt run-all apply

# Plan all modules
terragrunt run-all plan

# Destroy all modules (reverse dependency order)
terragrunt run-all destroy

# Apply only modules matching a pattern
terragrunt run-all apply --terragrunt-include-dir "**/services/**"
```

### Useful Flags

```bash
# Apply with auto-approve
terragrunt apply --terragrunt-non-interactive

# Show detailed plan
terragrunt plan -detailed-exitcode

# Apply specific dependency first
terragrunt apply --terragrunt-dependency mysql

# Exclude certain modules
terragrunt run-all apply --terragrunt-exclude-dir "**/conflict-*"
```

### Command Flow Example

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant TG as Terragrunt
    participant MySQL as MySQL Module
    participant App as App Module
    participant TF as Terraform
    participant AWS as AWS Cloud

    Dev->>TG: terragrunt run-all apply
    TG->>TG: Build dependency graph
    TG->>MySQL: Apply MySQL first (dependency)
    MySQL->>TF: terraform apply
    TF->>AWS: Create RDS instance
    AWS-->>TF: MySQL created
    TF-->>MySQL: Outputs: address, port
    MySQL-->>TG: MySQL complete
    TG->>App: Apply App (depends on MySQL)
    App->>App: Read dependency.mysql.outputs
    App->>TF: terraform apply (with MySQL outputs)
    TF->>AWS: Create ALB, ASG, etc.
    AWS-->>TF: App deployed
    TF-->>App: App complete
    App-->>TG: All modules applied
    TG-->>Dev: Success!
```

---

## Best Practices

### 1. Directory Structure

```mermaid
graph TD
    Root[Repository Root] --> Live[live/]
    Root --> Modules[modules/]
    Root --> Examples[examples/]
    
    Live --> Stage[stage/]
    Live --> Prod[prod/]
    
    Stage --> StageRoot[terragrunt.hcl<br/>remote_state config]
    Stage --> DataStores[data-stores/]
    Stage --> Services[services/]
    
    DataStores --> MySQL[mysql/terragrunt.hcl]
    Services --> App[hello-world-app/terragrunt.hcl]
    
    style StageRoot fill:#51cf66,color:#fff
    style MySQL fill:#339af0,color:#fff
    style App fill:#ff6b6b,color:#fff
```

**Recommended structure:**

```
terraform-repo/
├── live/
│   ├── stage/
│   │   ├── terragrunt.hcl          # Root config
│   │   ├── data-stores/
│   │   │   └── mysql/
│   │   │       └── terragrunt.hcl  # MySQL config
│   │   └── services/
│   │       └── hello-world-app/
│   │           └── terragrunt.hcl  # App config
│   └── prod/
│       └── ... (same structure)
├── modules/
│   ├── data-stores/
│   │   └── mysql/                  # Reusable module
│   └── services/
│       └── hello-world-app/        # Reusable module
└── examples/
    └── ... (standalone examples)
```

### 2. State File Organization

```mermaid
graph LR
    Bucket[S3 Bucket:<br/>terraform-state] --> Key1[data-stores/mysql/<br/>terraform.tfstate]
    Bucket --> Key2[services/hello-world-app/<br/>terraform.tfstate]
    Bucket --> Key3[services/another-app/<br/>terraform.tfstate]
    
    style Bucket fill:#51cf66,color:#fff
    style Key1 fill:#339af0,color:#fff
    style Key2 fill:#339af0,color:#fff
    style Key3 fill:#339af0,color:#fff
```

**Key naming pattern:**

```hcl
# In root terragrunt.hcl
key = "${path_relative_to_include()}/terraform.tfstate"

# Results in:
# - data-stores/mysql/terraform.tfstate
# - services/hello-world-app/terraform.tfstate
```

### 3. Dependency Management

```mermaid
flowchart TD
    A[Best Practice:<br/>Use dependency blocks] --> B[Avoid manual<br/>remote_state data sources]
    A --> C[Let Terragrunt<br/>handle ordering]
    A --> D[Automatic output<br/>passing]
    
    style A fill:#51cf66,color:#fff
    style B fill:#ff6b6b,color:#fff
    style C fill:#339af0,color:#fff
    style D fill:#339af0,color:#fff
```

**Good (with Terragrunt):**

```hcl
dependency "mysql" {
  config_path = "../../data-stores/mysql"
}

inputs = {
  mysql_config = dependency.mysql.outputs  # Automatic!
}
```

**Bad (without Terragrunt):**

```hcl
# Manual remote state lookup
data "terraform_remote_state" "mysql" {
  backend = "s3"
  config = {
    bucket = "my-bucket"
    key    = "data-stores/mysql/terraform.tfstate"
  }
}

# Easy to get wrong, no dependency ordering
```

### 4. Environment Variables

```mermaid
graph TD
    A[Use get_env for<br/>sensitive/config values] --> B[Backend bucket name]
    A --> C[Region]
    A --> D[Database credentials]
    
    B --> E[Not in version control]
    C --> E
    D --> E
    
    style A fill:#51cf66,color:#fff
    style E fill:#ffd93d,color:#000
```

**Example:**

```hcl
remote_state {
  config = {
    bucket = get_env("TERRAFORM_STATE_BUCKET", "default-bucket")
    region = get_env("AWS_REGION", "us-east-2")
  }
}

inputs = {
  # Credentials via environment variables
  # Set: export TF_VAR_db_username=admin
  # Set: export TF_VAR_db_password=secret
}
```

### 5. Testing Strategy

```mermaid
flowchart LR
    Dev[Developer] -->|Makes changes| Test[Test in examples/]
    Test -->|Validates| Stage[Deploy to stage/]
    Stage -->|Validates| Prod[Deploy to prod/]
    
    style Test fill:#ffd93d,color:#000
    style Stage fill:#339af0,color:#fff
    style Prod fill:#ff6b6b,color:#fff
```

**Workflow:**

1. **Examples/**: Test module changes in isolation
2. **Stage/**: Test full integration with dependencies
3. **Prod/**: Deploy after validation

---

## Real-World Example: Complete Flow

### Scenario: Deploying Hello World App

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant TG as Terragrunt
    participant MySQL as MySQL Module
    participant App as App Module
    participant S3 as S3 Backend
    participant AWS as AWS

    Note over Dev: cd live/stage/services/hello-world-app
    Dev->>TG: terragrunt apply
    
    Note over TG: Step 1: Read configuration
    TG->>TG: Read terragrunt.hcl
    TG->>TG: Find parent (find_in_parent_folders)
    TG->>TG: Merge remote_state config
    
    Note over TG: Step 2: Check dependencies
    TG->>TG: Detect dependency "mysql"
    TG->>MySQL: terragrunt apply (dependency)
    
    Note over MySQL: Deploy MySQL
    MySQL->>S3: Generate backend.tf
    MySQL->>AWS: Create RDS instance
    AWS-->>MySQL: MySQL ready
    MySQL-->>TG: Outputs: address, port
    
    Note over TG: Step 3: Generate backend for app
    TG->>S3: Generate backend.tf for app
    
    Note over TG: Step 4: Prepare inputs
    TG->>TG: Merge inputs + dependency outputs
    
    Note over TG: Step 5: Deploy app
    TG->>App: terraform apply (with MySQL outputs)
    App->>AWS: Create ALB, ASG, EC2
    AWS-->>App: App deployed
    App-->>TG: Complete
    TG-->>Dev: Success!
```

### Command Output Example

```bash
$ cd live/stage/services/hello-world-app
$ terragrunt apply

[terragrunt] 2024/01/15 10:30:00 Reading Terragrunt config at live/stage/services/hello-world-app/terragrunt.hcl
[terragrunt] 2024/01/15 10:30:00 Found parent terragrunt.hcl at live/stage/terragrunt.hcl
[terragrunt] 2024/01/15 10:30:00 Detected dependency: mysql
[terragrunt] 2024/01/15 10:30:00 Running command: terragrunt apply in ../../data-stores/mysql

# MySQL deployment output...
[terragrunt] 2024/01/15 10:32:00 Dependency mysql completed successfully
[terragrunt] 2024/01/15 10:32:00 Reading outputs from dependency mysql
[terragrunt] 2024/01/15 10:32:00 Generated backend.tf at live/stage/services/hello-world-app/backend.tf
[terragrunt] 2024/01/15 10:32:00 Running command: terraform init
[terragrunt] 2024/01/15 10:32:05 Running command: terraform apply

# App deployment output...
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:
alb_dns_name = "hello-world-stage-123456789.us-east-2.elb.amazonaws.com"
```

---

## Summary

Terragrunt provides:

✅ **DRY Configuration**: Define backend once, reuse everywhere  
✅ **Automatic Dependencies**: No manual ordering needed  
✅ **Team Standardization**: Consistent workflows  
✅ **State Management**: Organized, isolated state files  
✅ **Less Boilerplate**: No need to write backend.tf manually  

Use Terragrunt when:
- Working with multiple environments (dev/stage/prod)
- Managing complex module dependencies
- Need consistent backend configuration
- Working in a team environment

Stick with plain Terraform when:
- Simple, single-module projects
- No need for dependency management
- Prefer explicit over implicit configuration

