# Chapter 03: Terraform State Management - Complete Summary

This chapter explores two fundamental approaches to managing infrastructure across multiple environments using Terraform. By the end, you'll understand when and how to use workspaces and file layout patterns.

## Contents of This Chapter

### 1. **Workspaces Example** (Learning & Testing)

Located in: `workspaces-example/` and `workspaces-example-azure/`

**Purpose**: Understand the basics of Terraform workspaces with practical examples.

**Examples Included**:

- **AWS Version** (`workspaces-example/one-instance/`)
  - Simple EC2 instance with conditional sizing based on workspace
  - Uses S3 backend with DynamoDB locking
  - Demonstrates workspace switching and resource isolation
  - Good for: Learning, quick testing, local experimentation

- **Azure Version** (`workspaces-example-azure/one-instance/`)
  - Simple Virtual Machine with conditional sizing based on workspace
  - Uses Azure Blob Storage (with native locking via Leases)
  - Shows Azure's simpler backend architecture (no DynamoDB needed!)
  - Demonstrates cloud provider differences
  - Good for: Learning Azure, comparing cloud providers

**Key Concepts Demonstrated**:
- Creating and switching workspaces
- Using `terraform.workspace` variable for conditional logic
- Environment-specific resource sizing
- State file organization per workspace

### 2. **File Layout Example** (Production)

Located in: `file-layout-example/` and `file-layout-example-azure/`

**Purpose**: Professional infrastructure organization for production environments.

**Structure**:

```
file-layout-example/
├── global/s3/                      # Shared infrastructure
├── stage/                          # Staging environment
│   ├── data-stores/mysql/
│   └── services/webserver-cluster/
└── (Additional components as needed)
```

**Key Concepts Demonstrated**:
- Separate folders per environment
- Separate folders per component
- Consistent file naming (main.tf, variables.tf, outputs.tf)
- Partial backend configuration with backend.hcl
- Using `terraform_remote_state` for cross-component dependencies
- Production-ready isolation and safety

### 3. **Comprehensive Guides**

- **FILE_LAYOUT_GUIDE.md** - Complete comparison of workspaces vs file layout
- **file-layout-example/README.md** - Detailed file layout explanation
- **file-layout-example/BACKEND_SETUP.md** - Backend configuration walkthrough
- **workspaces-example/README.md** - Workspaces strengths and limitations
- **workspaces-example-azure/README.md** - Azure-specific workspace example

---

## Quick Comparison: Workspaces vs File Layout

### Workspaces

**When to Use**:
- ✅ Learning Terraform
- ✅ Local development and testing
- ✅ Quick temporary experiments
- ✅ Non-critical infrastructure

**Advantages**:
- Simple to learn and use
- Minimal setup required
- Good for understanding state basics
- Easy workspace switching

**Disadvantages**:
- Hidden from code (workspace names not visible)
- Shared backend credentials for all workspaces
- Error-prone (easy to destroy wrong environment)
- Not suitable for production
- No team access control separation

**Example**:
```bash
terraform workspace new staging
terraform apply  # Everyone can access!
```

### File Layout

**When to Use**:
- ✅ Production infrastructure
- ✅ Multi-team projects
- ✅ Different access controls per environment
- ✅ Compliance/security requirements

**Advantages**:
- Clear code organization (visible in version control)
- Complete isolation (separate state files)
- Different credentials per environment
- Separate access controls (via IAM/RBAC)
- Production-ready
- Audit trail friendly

**Disadvantages**:
- Multiple commands needed (more complex workflows)
- Code duplication across environments
- Longer learning curve
- Cross-folder dependencies are verbose

**Example**:
```bash
cd stage/services/webserver && terraform apply    # Isolated
cd prod/services/webserver && terraform apply     # Different creds
```

---

## Directory Structure Explained

### Top Level: Environments

```
global/      ← Resources shared across all environments
stage/       ← Pre-production testing environment
prod/        ← Production environment
mgmt/        ← Optional: DevOps/management tools
```

Each environment folder contains the SAME component structure:

### Middle Level: Components

```
data-stores/     ← Databases (MySQL, PostgreSQL, etc.)
services/        ← Applications (web servers, APIs, etc.)
vpc/             ← Network infrastructure (optional)
```

Each component is a complete, independent Terraform configuration.

### Bottom Level: Files

```
main.tf          ← Resources and data sources
variables.tf     ← Input variables
outputs.tf       ← Output values
dependencies.tf  ← External data sources (optional)
providers.tf     ← Provider configuration (optional)
README.md        ← Documentation
```

**Why This Structure?**
- Mirror your infrastructure organization
- Easy to navigate (predictable file locations)
- Version control friendly (clear folder structure)
- Team friendly (obvious what goes where)

---

## State Management Architecture

### AWS Approach (S3 + DynamoDB)

```
Terraform State Backend:
┌─────────────────────┐
│   S3 Bucket         │ ← Stores terraform.tfstate files
│   ├── env:/default/ │
│   ├── env:/dev/     │
│   └── env:/prod/    │
└─────────────────────┘

┌─────────────────────┐
│   DynamoDB Table    │ ← Handles state locking
│   (External)        │   Prevents concurrent modifications
└─────────────────────┘
```

**Components**: 2 resources (S3 + DynamoDB)
**Locking**: External database required
**Cost**: ~$2-5/month

### Azure Approach (Storage Account)

```
Terraform State Backend:
┌─────────────────────┐
│  Storage Account    │ ← Stores state files
│  ├── env:/default/  │
│  ├── env:/dev/      │
│  └── env:/prod/     │
│                     │
│  Blob Leases ◄──────┼─ Handles locking (built-in!)
│  (Built-in)         │
└─────────────────────┘
```

**Components**: 1 resource (Storage Account)
**Locking**: Native (Azure Blob Leases)
**Cost**: ~$1-5/month

**Key Difference**: Azure has SIMPLER, CHEAPER state management due to native locking!

---

## Learning Path

### For Beginners

**Step 1**: Start with workspaces to understand:
- What state files are
- How Terraform manages state
- Basics of multiple environments
- Using `terraform.workspace` variable

```bash
cd workspaces-example/
terraform workspace new dev
terraform apply
```

### For Production

**Step 1**: Understand file layout organization
```bash
cd file-layout-example/
# Study the folder structure
# Read global/s3/README.md
```

**Step 2**: Deploy infrastructure
```bash
cd global/s3 && terraform apply          # Shared resources first
cd stage/data-stores/mysql && terraform apply   # Then databases
cd stage/services/webserver && terraform apply  # Then apps
```

**Step 3**: Scale with modules (Chapter 4)
- Reduce code duplication
- Create reusable components
- Share patterns across environments

**Step 4**: Automate with Terragrunt (Chapter 10)
- Run commands across multiple folders
- Reduce boilerplate configuration
- Manage complex dependencies

---

## Common Patterns

### Pattern 1: Testing New Features

**Use Workspaces for**:
```bash
# Developer branch: test new database schema
terraform workspace new test-schema
terraform apply
# Test everything
terraform destroy
terraform workspace delete test-schema
```

### Pattern 2: Multiple Environments

**Use File Layout for**:
```bash
# Staging environment
cd stage/services/app && terraform apply

# Production environment (separate, safer)
cd prod/services/app && terraform apply

# Different credentials, different permissions!
```

### Pattern 3: Team Collaboration

**Use File Layout with IAM Policies**:
```json
// Developer: Can only access staging
{
  "Resource": "arn:aws:s3:::bucket/stage/*"
}

// DevOps: Can access production
{
  "Resource": "arn:aws:s3:::bucket/prod/*"
}
```

### Pattern 4: Cost Control

**Use File Layout with different sizes**:
```hcl
# stage/services/app/variables.tf
variable "instance_type" {
  default = "t3.micro"  # Cheap: ~$10/month
}

# prod/services/app/variables.tf
variable "instance_type" {
  default = "t3.xlarge"  # Powerful: ~$300/month
}
```

---

## Key Takeaways

### Workspaces ❓

- Single configuration, multiple state files
- Same backend credentials for all workspaces
- Hidden from code (error-prone)
- Good for learning, testing, experimenting
- NOT suitable for production

### File Layout ✅

- Multiple configurations, organized by environment and component
- Can use different backends per environment
- Can enforce different access controls
- Clear code organization (visible in git)
- Production-ready approach

### Azure vs AWS

Azure is simpler:
- No DynamoDB equivalent needed
- Native blob locking (Azure Leases)
- Fewer moving parts
- Potentially cheaper
- Same concepts, different implementation

---

## Recommended Workflow

### For Your Project

1. **Start**: Use file layout from day 1 for production
   ```
   - Safer (no workspace confusion)
   - Professional (clear organization)
   - Scalable (ready for growth)
   ```

2. **Use workspaces only for**:
   - Local testing during development
   - Learning Terraform concepts
   - Temporary experiments (cleaned up after)

3. **As you grow**:
   - Add Terraform modules (Chapter 4) to reduce duplication
   - Add Terragrunt (Chapter 10) for automation
   - Implement comprehensive access controls

### Example Repository Structure

```
myapp-infrastructure/
├── README.md
├── terraform/
│   ├── FILE_LAYOUT_GUIDE.md          # Your guide to structure
│   ├── ARCHITECTURE.md                # How environments relate
│   ├── backend.hcl                    # Shared backend config
│   │
│   ├── global/
│   │   ├── s3/                       # State infrastructure
│   │   ├── iam/                      # Identity & access
│   │   └── vpc-peering/              # Network connections
│   │
│   ├── stage/
│   │   ├── vpc/
│   │   ├── data-stores/
│   │   └── services/
│   │
│   └── prod/
│       ├── vpc/
│       ├── data-stores/
│       └── services/
│
├── modules/                           # Reusable components (Chapter 4)
│   ├── webserver-cluster/
│   ├── database/
│   └── load-balancer/
│
└── .github/
    └── workflows/                    # CI/CD automation
        └── terraform.yml
```

---

## Important Warnings ⚠️

### Never Do This!

```bash
# ❌ Wrong: Forget which workspace you're in
terraform apply  # Which environment did I just destroy?

# ❌ Wrong: Give everyone access to all workspaces
# (Same credentials for all workspaces)

# ❌ Wrong: Use workspaces for production environments
# (No isolation, no access control, error-prone)
```

### Always Do This!

```bash
# ✅ Right: Clear folder structure shows environment
cd prod/services/app && terraform apply

# ✅ Right: Different credentials per environment
ARM_SUBSCRIPTION_ID=prod-sub terraform apply

# ✅ Right: Code review for production changes
# (Git shows which files changed, easy to review)

# ✅ Right: Destroy is explicit and careful
terraform destroy  # Inside prod folder, clearly visible
```

---

## Next Steps

### To Go Deeper

1. **Chapter 4**: Terraform Modules
   - Reduce code duplication
   - Create reusable infrastructure components
   - Share patterns across environments

2. **Chapter 5+**: Specialized Topics
   - Organizing code for large organizations
   - Integrating with CI/CD pipelines
   - Managing secrets and sensitive data

3. **Chapter 10**: Terragrunt
   - Automate multi-folder deployments
   - Generate common configurations
   - Manage dependencies between modules

### Additional Resources

- [Terraform State Documentation](https://www.terraform.io/docs/language/state/)
- [Remote State Management](https://www.terraform.io/docs/language/state/remote-state-data.html)
- [Workspaces Documentation](https://www.terraform.io/docs/language/state/workspaces.html)
- [Best Practices](https://www.terraform.io/docs/cloud/recommended-practices/)

---

## Quick Reference

### Create and Switch Workspaces

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace select dev
terraform workspace list
terraform workspace delete test
```

### File Layout Navigation

```bash
# Navigate to specific environment and component
cd stage/services/webserver-cluster

# Initialize with shared backend config
terraform init -backend-config=../../backend.hcl

# Plan and apply (isolated to this component)
terraform plan
terraform apply

# View outputs from this component
terraform output
```

### Cross-Component Dependencies

```hcl
# Reference another component's outputs
data "terraform_remote_state" "mysql" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "stage/data-stores/mysql/terraform.tfstate"
  }
}

# Use the outputs
resource "aws_instance" "web" {
  user_data = "mysql://${data.terraform_remote_state.mysql.outputs.endpoint}"
}
```

---

## Summary

| Concept | Purpose | When to Use |
|---------|---------|------------|
| **Workspaces** | Multiple state files in single config | Learning, testing, experiments |
| **File Layout** | Multiple configs, organized structure | Production, teams, compliance |
| **Backend Config** | Remote state storage | Always for production |
| **Modules** | Code reusability (Chapter 4) | When code repeats |
| **Terragrunt** | Multi-folder automation (Chapter 10) | Large projects |

**Golden Rule**:
- Use file layout for anything that matters
- Use workspaces only for throwaway experiments
- When in doubt, use file layout

---

## Chapter Files Map

```
03-terraform-state/
│
├── workspaces-example/              # AWS workspaces (learning)
│   └── one-instance/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── workspaces-example-azure/        # Azure workspaces (learning)
│   └── one-instance/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── file-layout-example/             # AWS file layout (production)
│   ├── backend.hcl
│   ├── BACKEND_SETUP.md
│   ├── global/s3/
│   ├── stage/data-stores/mysql/
│   ├── stage/services/webserver-cluster/
│   └── README.md
│
├── file-layout-example-azure/       # Azure file layout (production)
│   ├── backend.hcl
│   ├── global/storage/
│   ├── stage/data-stores/mysql/
│   └── stage/services/webserver-cluster/
│
├── FILE_LAYOUT_GUIDE.md             # This comparison guide
└── CHAPTER_SUMMARY.md               # Chapter overview (this file)
```

---

## Getting Help

Each example includes comprehensive README files:

- Need to understand workspaces? → Read `workspaces-example/README.md`
- Need to understand file layout? → Read `file-layout-example/README.md`
- Confused about backend config? → Read `file-layout-example/BACKEND_SETUP.md`
- Comparing approaches? → Read `FILE_LAYOUT_GUIDE.md`
- Want AWS vs Azure? → Compare workspaces-example vs workspaces-example-azure

Good luck! 🚀
