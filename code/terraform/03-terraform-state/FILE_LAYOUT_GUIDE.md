# File Layout vs Workspaces: Complete Guide

This document summarizes the two main approaches to managing multiple environments in Terraform: **workspaces** and **file layout**. By the end, you'll understand when to use each approach and why file layout is recommended for production.

## Quick Summary

| Aspect | Workspaces | File Layout |
|--------|-----------|------------|
| **Best For** | Quick local testing | Production infrastructure |
| **State Storage** | Same backend | Separate state files/keys |
| **Access Control** | Shared credentials | Different credentials per env |
| **Code Organization** | Hidden from code | Clear folder structure |
| **Safety** | Error-prone | Safe and isolated |
| **Suitable for Prod** | ❌ No | ✅ Yes |
| **Team Friendly** | ❌ Limited | ✅ Excellent |

---

## Isolation Mechanisms: How Each Approach Isolates Environments

Understanding HOW each approach isolates multiple environments is critical for making the right choice. This section explains the technical mechanisms behind isolation in workspaces vs file layout.

### Logical Isolation via Workspaces

**Concept**: Workspaces use a **single Terraform configuration with conditional logic** to manage multiple environments. The same code (main.tf) serves all workspaces.

**Mechanism**:
```bash
# Create workspaces
terraform workspace new prod
terraform workspace new dev
terraform workspace select dev    # Context switches to "dev"

# All state files stored in SAME backend with magic paths
s3://terraform-state/
└── env:/
    ├── default/terraform.tfstate       # Production
    ├── dev/terraform.tfstate           # Development
    └── staging/terraform.tfstate       # Staging
```

**How It Works**:
1. You define resources in **one main.tf** file
2. You use `terraform.workspace` variable for conditionals:
   ```hcl
   # Single code, conditional sizing
   vm_size = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
   name    = "server-${terraform.workspace}"
   ```
3. Running `terraform apply` with workspace "dev" selected uses only the dev state file
4. Running `terraform apply` with workspace "prod" selected uses only the prod state file
5. **All workspaces share the same backend credentials and configurations**

**Backend Behavior (AWS)**:
```
When using S3 backend with workspaces:
- Backend bucket: s3://my-terraform-state/
- Workspace "default": Stores state at env:/default/terraform.tfstate
- Workspace "dev": Stores state at env:/dev/terraform.tfstate
- Workspace "prod": Stores state at env:/prod/terraform.tfstate
- ⚠️ Path generation is AUTOMATIC (magic paths)
- ⚠️ All workspaces accessible with SAME S3 credentials
```

**Backend Behavior (Azure)**:
```
When using Azure Storage backend with workspaces:
- Backend container: tfstate/
- Workspace "default": Stores at env:/default/terraform.tfstate
- Workspace "dev": Stores at env:/dev/terraform.tfstate
- Workspace "prod": Stores at env:/prod/terraform.tfstate
- ⚠️ Path generation is AUTOMATIC
- ⚠️ All workspaces share SAME Storage Account credentials
- ✅ Azure Blob Leases handle locking (built-in)
```

**Advantages of Logical Isolation**:
- ✅ **Rapid ephemeral environments**: Create test workspace, destroy, repeat in seconds
- ✅ **Zero code duplication**: Single main.tf handles all environments
- ✅ **Simple mental model**: All workspaces use identical base configuration
- ✅ **Easy to understand**: Straightforward commands (workspace new/select)
- ✅ **Minimal setup**: No folder structure to maintain

**Disadvantages of Logical Isolation**:
- ❌ **Human error risk**: Easy to forget which workspace is selected before `terraform destroy`
- ❌ **Shared security**: One exposed credential grants access to ALL environments
- ❌ **Invisible workspace names**: Workspace selection doesn't appear in code or version control
- ❌ **Dirty code**: Conditional logic scattered throughout main.tf (`if workspace == "prod" then ...`)
- ❌ **No RBAC separation**: Can't grant different IAM permissions per workspace
- ❌ **Shared state locking**: One DynamoDB table or Azure Lease for all workspaces
- ❌ **Workspace drift**: Hard to see what's different between workspaces in version control

**Real-World Risk Example**:
```bash
# Developer in production debugging
$ terraform workspace list
  default
* prod
$ terraform destroy   # Meant to destroy test resources...
# ❌ DISASTER: Just destroyed production!

# Why it happened:
# 1. "prod" doesn't appear in file system (invisible)
# 2. Forgot which workspace was selected
# 3. No access control to prevent it
# 4. Same credentials work for all workspaces
```

---

### Physical Isolation via File Layout

**Concept**: File layout uses **separate physical directories and separate Terraform configurations** for each environment. Each environment is completely independent.

**Mechanism**:
```bash
# Navigate to specific environment
cd prod/services/webserver-cluster

# Initialize and deploy THAT configuration only
terraform init
terraform apply

# To switch environments, physically navigate
cd ../../../stage/services/webserver-cluster

# This is a DIFFERENT configuration with DIFFERENT backend
terraform init
terraform apply
```

**Directory Structure**:
```
terraform/
├── global/                              # Shared cross-environment
│   └── s3/                             # State backend infrastructure
│       ├── main.tf
│       └── backend config (separate)
├── stage/                              # Staging environment (completely separate)
│   ├── data-stores/mysql/
│   │   ├── main.tf                     # Different config than prod
│   │   └── backend config
│   └── services/webserver-cluster/
│       ├── main.tf                     # Different code than prod
│       └── backend config
└── prod/                               # Production environment (completely separate)
    ├── data-stores/mysql/
    │   ├── main.tf                     # Different config than stage
    │   └── backend config
    └── services/webserver-cluster/
        ├── main.tf                     # Different code than stage
        └── backend config
```

**How It Works**:
1. You create **separate main.tf files** in stage/ and prod/
2. Stage configuration can be different from prod:
   ```hcl
   # stage/services/webserver/variables.tf
   variable "vm_size" {
     default = "t3.micro"    # Cheap
   }

   # prod/services/webserver/variables.tf
   variable "vm_size" {
     default = "t3.large"    # Powerful
   }
   ```
3. Each folder has its **own independent backend configuration**
4. State files are stored in **separate locations** (or at least with clear separation)
5. **Different credentials can be used per environment** via IAM/RBAC

**Backend Behavior (AWS with File Layout)**:
```
When using S3 backend with file layout (separate buckets):

Option 1: Single bucket, clear key separation
s3://terraform-state/
├── stage/data-stores/mysql/terraform.tfstate
├── stage/services/webserver-cluster/terraform.tfstate
├── prod/data-stores/mysql/terraform.tfstate
└── prod/services/webserver-cluster/terraform.tfstate

Option 2: Separate buckets per environment (highest isolation)
s3://terraform-state-stage/
├── data-stores/mysql/terraform.tfstate
└── services/webserver-cluster/terraform.tfstate

s3://terraform-state-prod/
├── data-stores/mysql/terraform.tfstate
└── services/webserver-cluster/terraform.tfstate

🔑 Backend is EXPLICITLY configured in each folder (NOT magic paths)
🔑 Can use DIFFERENT IAM credentials per environment
🔑 Each folder can have INDEPENDENT DynamoDB locks
```

**Backend Behavior (Azure with File Layout)**:
```
When using Azure Storage backend with file layout:

Option 1: Single Storage Account, clear path separation
Storage Account: terraform-state
└── Container: tfstate/
    ├── stage/data-stores/mysql/terraform.tfstate
    ├── stage/services/webserver-cluster/terraform.tfstate
    ├── prod/data-stores/mysql/terraform.tfstate
    └── prod/services/webserver-cluster/terraform.tfstate

Option 2: Separate Storage Accounts per environment (highest isolation)
Stage Storage Account: terraform-state-stage
└── Container: tfstate/
    ├── data-stores/mysql/terraform.tfstate
    └── services/webserver-cluster/terraform.tfstate

Prod Storage Account: terraform-state-prod
└── Container: tfstate/
    ├── data-stores/mysql/terraform.tfstate
    └── services/webserver-cluster/terraform.tfstate

🔑 Backend is EXPLICITLY configured (no magic paths)
🔑 Can use DIFFERENT Storage Account keys per environment
🔑 Each Storage Account can have independent RBAC policies
```

**Advantages of Physical Isolation**:
- ✅ **Crystal clear visibility**: Folder path shows exactly which environment you're in
- ✅ **RBAC/IAM separation**: Different teams/people can have different permissions
- ✅ **Security compartmentalization**: Compromised staging doesn't affect production
- ✅ **Version control clarity**: Git diff shows exactly which files changed per environment
- ✅ **Mistake prevention**: Must navigate to prod folder to affect production
- ✅ **Code review enforcement**: Can require approval before prod changes
- ✅ **Compliance friendly**: Audit logs show exactly which environment was modified when
- ✅ **Flexible scaling**: Can use different backend solutions per environment
- ✅ **Independent state**: One environment's state corruption doesn't affect others

**Disadvantages of Physical Isolation**:
- ❌ **More boilerplate**: Multiple files vs single main.tf
- ❌ **Code duplication**: Stage and prod have similar code (mitigated with modules)
- ❌ **Cross-environment dependencies**: Need `terraform_remote_state` to reference other environments
- ❌ **More complex workflows**: Multiple terraform init/apply commands vs single configuration
- ❌ **Longer learning curve**: Must understand folder navigation and backends

**Real-World Safety Example**:
```bash
# Developer in production environment
$ pwd
/prod/services/webserver-cluster

# To make a destructive change:
$ terraform destroy

# ✅ SAFE: Multiple protections triggered:
# 1. pwd output shows "/prod/" (explicit visibility)
# 2. Code review required before merging (infrastructure-as-code practice)
# 3. Different IAM credentials required (enforced by CI/CD)
# 4. Separate state file - can't accidentally affect staging
# 5. Historical audit trail in version control
```

---

### Comparison: Isolation Mechanisms

| Characteristic | Workspaces (Logical) | File Layout (Physical) |
|---|---|---|
| **Approach** | Single code, logical context switching | Separate code, separate directories |
| **Backend Storage** | Single bucket/container (magic paths) | Separate buckets/containers (explicit) |
| **Credentials** | Shared for all workspaces | Different per environment (possible) |
| **RBAC/IAM Control** | All workspaces same permissions | Different permissions per environment |
| **Visibility** | Invisible (hidden in state) | Visible (in folder structure) |
| **Security Risk** | One credential = all environments | Credentials are compartmentalized |
| **Code Duplication** | None (conditional logic) | Moderate (mitigated with modules) |
| **Human Error Risk** | High (easy to forget workspace) | Low (must navigate to folder) |
| **Recommended For** | Ephemeral/temporary | Production/long-duration |

---

### Conclusion: Which Isolation is Better?

**Use File Layout (Physical Isolation) for**:
- 🏢 Production infrastructure
- 👥 Multi-team environments (different access controls)
- 🔐 Compliance-sensitive workloads (PCI, HIPAA, SOC 2)
- 🚀 Long-duration environments (stage, prod, dr)
- 🛡️ High-risk infrastructure (user-facing, critical services)
- 💰 Cost control (different sizes per environment)

**File Layout provides superior isolation through**:
- Separate Terraform configurations (easy to review)
- Separate state files (independent recovery)
- Separate credentials (RBAC enforcement)
- Version control visibility (clear history)

**Use Workspaces (Logical Isolation) only for**:
- 🧪 Local development testing
- 📚 Learning Terraform basics
- 🔬 Ephemeral/throwaway environments
- ⚡ Quick experiments (created and destroyed in minutes)

**Workspaces acceptable only when**:
- Single developer (no team collaboration needed)
- Environment destroyed within hours (not persistent)
- No production data involved (testing only)
- No compliance requirements

**Golden Rule**:
> If infrastructure will exist for more than a few hours, or multiple people need different access levels, use **file layout**. Workspaces are for temporary throwaway environments only.

---



### What Are Workspaces?

Workspaces allow you to manage **multiple state files** within a single Terraform configuration:

```bash
# Create and switch between workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace select dev       # Now in dev workspace
terraform apply                      # Applies to dev state only
```

### How Workspaces Work

All state files stored in same backend:

```
s3://terraform-state/
└── env:/
    ├── default/terraform.tfstate
    ├── dev/terraform.tfstate
    └── staging/terraform.tfstate
```

All workspaces use **same authentication and backend configuration**.

### Advantages of Workspaces

✅ **Easy to learn** - Simple commands, minimal setup
✅ **Quick testing** - Spin up test environments fast
✅ **Low overhead** - Single configuration file
✅ **Great for learning** - Good for understanding Terraform basics

### Disadvantages of Workspaces

❌ **Hidden from code** - Workspace names aren't visible in version control
❌ **Shared backend** - All workspaces use same credentials and access controls
❌ **Easy to forget** - It's simple to forget which workspace you're in
❌ **Shared infrastructure credentials** - One compromised credential exposes all environments
❌ **Not production-ready** - High risk of accidentally destroying wrong environment
❌ **No team isolation** - All team members can access all workspaces
❌ **Unsuitable for compliance** - Can't implement environment-specific access controls

### When to Use Workspaces

Use workspaces ONLY for:

- 🔬 **Local development testing** - Testing changes before committing
- 📚 **Learning Terraform** - Understanding how state and apply work
- 🧪 **Temporary experiments** - Quick throwaway infrastructure
- 🪤 **Non-critical infrastructure** - Nothing that users depend on

### Example: Workspace Use Case

```bash
# Developer testing a new database schema
terraform workspace new test-schema
terraform apply                              # Applies only to test-schema workspace
# Test the schema, make sure it works
terraform destroy                            # Destroys only test-schema
terraform workspace delete test-schema       # Clean up
```

---

## Understanding File Layout

### What Is File Layout?

File layout organizes Terraform code into **separate folders** for each environment and component:

```
terraform/
├── global/s3/                   # Shared resources
├── stage/                       # Staging environment
│   ├── data-stores/mysql/
│   └── services/webserver-cluster/
└── prod/                        # Production environment
    ├── data-stores/mysql/
    └── services/webserver-cluster/
```

Each folder is a **complete, independent Terraform configuration**.

### How File Layout Works

Each component gets its own state file:

```
s3://terraform-state/
├── global/s3/terraform.tfstate
├── stage/data-stores/mysql/terraform.tfstate
├── stage/services/webserver-cluster/terraform.tfstate
├── prod/data-stores/mysql/terraform.tfstate
└── prod/services/webserver-cluster/terraform.tfstate
```

Different folders can use **different credentials and backends**.

### Directory Structure

```
Stage 1: Environments (top level)
├── global/      ← Shared resources across all environments
├── stage/       ← Pre-production testing environment
├── prod/        ← Production environment (user-facing)
└── mgmt/        ← Optional: DevOps tools (bastion, CI server)

Stage 2: Components (within each environment)
└── stage/
    ├── vpc/                ← Network infrastructure
    ├── data-stores/        ← Databases
    │   └── mysql/
    └── services/           ← Applications
        └── webserver-cluster/

Stage 3: Files (within each component)
└── stage/services/webserver-cluster/
    ├── main.tf             ← Resources
    ├── variables.tf        ← Input variables
    ├── outputs.tf          ← Outputs
    ├── dependencies.tf     ← External data sources (optional)
    ├── providers.tf        ← Provider configuration (optional)
    └── README.md           ← Documentation
```

### Advantages of File Layout

✅ **Clear code organization** - Folder structure shows environment setup
✅ **Complete isolation** - Separate state files, separate backends
✅ **Separate credentials** - Different access controls per environment
✅ **Production-ready** - Safe for user-facing infrastructure
✅ **Team friendly** - Multiple teams can work independently
✅ **Compliance-ready** - Can enforce environment-specific access policies
✅ **Audit trail** - Easy to see what's in each environment
✅ **Version control friendly** - Folder structure is visible in git
✅ **Safer deployments** - Mistakes are isolated to one component

### Disadvantages of File Layout

❌ **Multiple commands required** - Can't create entire environment with one command
❌ **Code duplication** - Similar code in stage/ and prod/
❌ **Complex dependencies** - Need `terraform_remote_state` for cross-folder references
❌ **Longer learning curve** - More complex than workspaces

### When to Use File Layout

Use file layout for:

- 🏢 **Production infrastructure** - Anything users depend on
- 👥 **Multi-team projects** - Multiple teams working independently
- 🔐 **Compliance requirements** - Need separate access controls
- 📊 **Multiple environments** - staging, prod, dr, etc.
- 🚀 **Growing projects** - Scaling from startup to mature company
- 🛡️ **Safety critical** - High risk of damage from mistakes

### Example: File Layout Workflow

```bash
# Deploy shared infrastructure first
cd global/s3
terraform init -backend-config=../backend.hcl
terraform apply

# Deploy staging environment
cd stage/data-stores/mysql
terraform init -backend-config=../../backend.hcl
terraform apply

cd stage/services/webserver-cluster
terraform init -backend-config=../../backend.hcl
terraform apply

# Deploy production independently (separate, reviewed)
cd prod/data-stores/mysql
terraform init -backend-config=../../backend.hcl
terraform apply

cd prod/services/webserver-cluster
terraform init -backend-config=../../backend.hcl
terraform apply
```

Each `cd` command enters a **completely isolated Terraform configuration**.

---

## Detailed Comparison

### 1. Code Organization

**Workspaces:**
```bash
$ ls
main.tf                    # Single configuration file
variables.tf              # All variables in one place
outputs.tf               # All outputs in one place
terraform.tfstate        # Only one state file visible
```
Workspace names are invisible!

**File Layout:**
```bash
$ tree
stage/
├── data-stores/mysql/   # Clear component organization
│   └── main.tf
└── services/webserver-cluster/
    └── main.tf
prod/
├── data-stores/mysql/   # Same structure, different environment
│   └── main.tf
└── services/webserver-cluster/
    └── main.tf
```
Environments and components are immediately obvious!

### 2. State File Management

**Workspaces:**
```
Same backend, multiple state files:
s3://my-bucket/
└── env:/
    ├── default/terraform.tfstate
    ├── staging/terraform.tfstate    ← All in same bucket
    └── prod/terraform.tfstate       ← Shared access
```

Risk: One credential compromises all environments.

**File Layout:**
```
Separate state files per component:
s3://my-bucket/
├── stage/data-stores/mysql/terraform.tfstate
├── stage/services/webserver-cluster/terraform.tfstate
├── prod/data-stores/mysql/terraform.tfstate
└── prod/services/webserver-cluster/terraform.tfstate
```

Benefit: Can use different backends or IAM roles per environment.

### 3. Access Control

**Workspaces:**
```
AWS IAM Policy:
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/env:/*"  ← All workspaces
}
```
All workspaces are accessible to anyone with this policy.

**File Layout:**
```
AWS IAM Policy (Developer):
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/stage/*"  ← Only staging
}

AWS IAM Policy (Ops):
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/prod/*"   ← Only production
}
```
Different teams can have different permissions!

### 4. Mistake Risk

**Workspaces:**
```bash
# Developer thinks they're in staging
terraform destroy

# Actually destroys production!
# Huge problem because:
# 1. No folder indication of which environment
# 2. Same credentials for all workspaces
# 3. No access control protection
```

**File Layout:**
```bash
# Developer working in staging
cd stage/services/webserver-cluster && terraform destroy

# Same command in prod requires:
cd prod/services/webserver-cluster && terraform destroy

# Additional protection:
# 1. Must navigate to prod folder (obvious)
# 2. Can require different IAM credentials for prod
# 3. Folder structure is version controlled
# 4. Can require code review for prod changes
```

### 5. Team Collaboration

**Workspaces:**
```bash
# Developer 1
terraform workspace select staging && terraform apply

# Developer 2  (immediately after)
terraform workspace select staging && terraform apply

# Problem: Did I remember to switch workspaces?
# Did Developer 1 leave in staging workspace?
# State lock might be active
# Confusion and conflicts
```

**File Layout:**
```bash
# Developer 1
cd stage/services/webserver-cluster && terraform apply

# Developer 2 (immediately after)
cd stage/data-stores/mysql && terraform apply

# Different folders = no conflicts
# Clear which environment/component
# No workspace confusion
```

---

## Decision Matrix

Use **Workspaces** if:
- ✅ This is a learning project
- ✅ Not production infrastructure
- ✅ Single developer testing locally
- ✅ Quick throwaway experiments
- ✅ No access control requirements

Use **File Layout** if:
- ✅ Production infrastructure
- ✅ Multiple team members
- ✅ Need different access controls per environment
- ✅ Multiple environments (stage, prod, dr)
- ✅ Compliance/security requirements
- ✅ High risk of damage from mistakes

---

## Migration Path

If you're currently using workspaces, here's how to migrate:

### Step 1: Understand Your Current Setup

```bash
# See all workspaces
terraform workspace list

# Check what's deployed
terraform state list
```

### Step 2: Create File Layout Structure

```bash
mkdir -p stage/services/myapp
mkdir -p prod/services/myapp
mkdir -p global/s3
```

### Step 3: Copy Configuration

```bash
# Copy main.tf to file layout
cp main.tf stage/services/myapp/

# Note: Remove workspace-specific logic like:
# instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
```

### Step 4: Update Variables

```hcl
# stage/services/myapp/variables.tf
variable "instance_type" {
  default = "t3.micro"  # Staging-specific
}

# prod/services/myapp/variables.tf
variable "instance_type" {
  default = "t3.large"  # Production-specific
}
```

### Step 5: Deploy to File Layout

```bash
# Backup old state
terraform state pull > backup.tfstate

# Initialize new file layout
cd stage/services/myapp && terraform init
terraform apply  # Redeploys from state

# Repeat for prod
cd prod/services/myapp && terraform init
terraform apply
```

### Step 6: Clean Up Workspaces

```bash
# Delete old workspaces (keep state backed up first!)
terraform workspace delete staging
terraform workspace delete production
```

---

## Production Recommendations

### For Small Projects (1-5 developers)

Start with file layout immediately:

```
terraform/
├── global/
└── prod/
    ├── services/
    └── data-stores/
```

Simple, safe, professional.

### For Growing Projects (5-20 developers)

Use file layout + modules:

```
terraform/
├── modules/                    # Reusable components
│   ├── webserver-cluster/
│   └── database/
├── global/
├── stage/
└── prod/
```

See Chapter 4 for modules.

### For Large Projects (20+ developers)

Use file layout + modules + Terragrunt:

```
terraform/
├── terragrunt.hcl              # Central configuration
├── modules/                    # Reusable code
├── global/
├── stage/
└── prod/
```

See Chapter 10 for Terragrunt.

---

## Examples in This Chapter

### Workspaces Example

Location: `workspaces-example/`

Demonstrates:
- Creating workspaces
- Deploying to different workspaces
- Using `terraform.workspace` variable
- Limitations of workspaces

**⚠️ Note:** This is for learning only. Not recommended for production.

### File Layout Example

Location: `file-layout-example/`

Demonstrates:
- Proper directory structure
- Multiple components (vpc, data-stores, services)
- Separate state files per component
- Using `terraform_remote_state` for dependencies
- Partial backend configuration with `backend.hcl`

**✅ Recommended:** Use this structure for your actual projects.

---

## Key Takeaways

1. **Workspaces** are useful for learning and local testing, but unsuitable for production
2. **File layout** is the production-ready approach with better isolation and safety
3. **File layout** matches your infrastructure organization (environments → components)
4. **Access control** is easier to implement with file layout
5. **Team collaboration** scales better with file layout
6. **Code organization** is clearer with file layout structure

---

## Next Steps

### To Learn More About File Layout:
- Read `file-layout-example/README.md` for detailed structure explanation
- See `file-layout-example/BACKEND_SETUP.md` for backend configuration
- Check each component's README for setup instructions

### To Go Deeper:
- **Chapter 4**: Terraform modules to reduce code duplication
- **Chapter 10**: Terragrunt for automating multi-folder deployments
- **Terraform Docs**: [State Management](https://www.terraform.io/docs/language/state/)
- **Terraform Docs**: [Remote State](https://www.terraform.io/docs/language/state/remote-state-data.html)

---

## Quick Reference Card

### File Layout Commands

```bash
# Initialize a component with shared backend config
cd stage/services/webserver-cluster
terraform init -backend-config=../../backend.hcl

# Plan changes (isolated to this component)
terraform plan

# Apply changes (isolated to this component)
terraform apply

# Switch to production (completely different folder)
cd ../../prod/services/webserver-cluster
terraform init -backend-config=../../backend.hcl
terraform apply  # Different state, different credentials possible
```

### File Layout Structure

```
terraform/
├── backend.hcl                              # Shared backend settings
├── FILE_LAYOUT_GUIDE.md                    # This guide
│
├── global/                                  # Cross-environment resources
│   └── s3/
│       ├── main.tf, variables.tf, outputs.tf
│       └── README.md
│
├── stage/                                   # Non-production environment
│   ├── data-stores/
│   │   └── mysql/
│   │       ├── main.tf, variables.tf, outputs.tf
│   │       └── README.md
│   └── services/
│       └── webserver-cluster/
│           ├── main.tf, variables.tf, outputs.tf
│           └── README.md
│
└── prod/                                    # Production environment
    ├── data-stores/
    └── services/
```

This structure is:
- ✅ Clear and organized
- ✅ Version control friendly
- ✅ Team collaborative
- ✅ Production-ready
- ✅ Audit trail friendly
