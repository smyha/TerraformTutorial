# Terraform Workspaces Example

This folder contains an example [Terraform](https://www.terraform.io/) configuration that demonstrates **Terraform Workspaces** for managing multiple environments (development, staging, production) from a single codebase.

## What are Terraform Workspaces?

Workspaces allow you to manage multiple **state files** and **variable sets** within the same Terraform configuration:

- **Multiple Environments**: Deploy the same infrastructure code to dev, staging, and production
- **Separate State Files**: Each workspace maintains its own state, preventing accidental modifications
- **Environment-Specific Configuration**: Use conditional logic to vary resources by environment
- **Simplified Management**: No need to duplicate code across directories

## How This Example Works

The configuration in `main.tf` deploys a single EC2 instance with **workspace-aware sizing**:

```text
Workspace: default  → Instance Type: t2.medium (production)
Workspace: dev      → Instance Type: t2.micro  (development)
Workspace: staging  → Instance Type: t2.micro  (staging)
```

The decision logic uses Terraform's conditional expression:

```hcl
instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
```

For more info, please see Chapter 3, "How to Manage Terraform State", of
*[Terraform: Up and Running](http://www.terraformupandrunning.com)*.

## Logical Isolation via Workspaces: How It Works

Understanding HOW workspaces achieve isolation is crucial for knowing when to use them.

### Concept

Workspaces provide **logical isolation** by using a **single Terraform configuration with conditional logic**. The same code (main.tf) serves all workspaces, with Terraform automatically managing separate state files.

### Mechanism

```bash
# Create and switch workspaces
terraform workspace new prod
terraform workspace select dev

# All workspaces use SAME backend with automatic path generation
s3://terraform-state/
└── env:/                    # Magic paths (automatic)
    ├── default/terraform.tfstate       # Production
    ├── dev/terraform.tfstate           # Development
    └── staging/terraform.tfstate       # Staging
```

### How Logical Isolation Works

1. **Single Configuration File**: All environments use the same main.tf:
   ```hcl
   # main.tf
   instance_type = terraform.workspace == "default" ? "t3.small" : "t3.micro"
   name          = "server-${terraform.workspace}"
   ```

2. **Context Switching**: You select which workspace to work with:
   ```bash
   terraform workspace select prod    # Now all applies go to prod state
   terraform apply                    # Uses prod state file only
   ```

3. **Automatic State Path Generation (Magic Paths)**: Terraform automatically uses the correct state file:
   ```
   When you run "terraform apply":
   1. Checks current workspace (e.g., "dev")
   2. Looks for state file at: s3://bucket/env:/dev/terraform.tfstate
   3. Applies changes only to that state
   ```

4. **Same Backend Credentials**: All workspaces share identical authentication:
   ```
   s3://terraform-state/
   └── All workspaces use SAME S3 credentials
   └── All workspaces use SAME DynamoDB locking
   └── All workspaces use SAME backend access controls
   ```

### AWS Backend Behavior with Workspaces

```
Backend: S3 with workspaces
S3 Bucket: terraform-state/

Workspace selection:
$ terraform workspace select dev
$ terraform apply
  → Uses: env:/dev/terraform.tfstate
  → Locking: terraform_locks table (shared)
  → Credentials: Same AWS_ACCESS_KEY_ID for all

$ terraform workspace select prod
$ terraform apply
  → Uses: env:/prod/terraform.tfstate
  → Locking: terraform_locks table (shared)
  → Credentials: SAME AWS_ACCESS_KEY_ID (no separation!)

⚠️ Key Point: Both workspaces accessible with same credentials
```

### Advantages of Logical Isolation

- ✅ **Zero code duplication**: Single main.tf handles all environments
- ✅ **Rapid ephemeral environments**: Create test workspace, destroy, repeat in seconds
- ✅ **Simple to understand**: Straightforward `workspace new/select` commands
- ✅ **Minimal setup**: No complex folder structure to maintain
- ✅ **Easy to learn**: Good mental model for Terraform basics

### Disadvantages of Logical Isolation

- ❌ **Shared backend credentials**: Same credentials = access to all workspaces
- ❌ **Invisible workspace selection**: Workspace names don't appear in file system
- ❌ **Human error risk**: Easy to forget which workspace is selected before `terraform destroy`
- ❌ **Dirty code**: Conditional logic scattered throughout configuration:
  ```hcl
  # Ugly: Conditional logic everywhere
  size = terraform.workspace == "prod" ? "large" : "small"
  replicas = terraform.workspace == "prod" ? 10 : 2
  backup_days = terraform.workspace == "prod" ? 30 : 7
  ```
- ❌ **No RBAC separation**: Can't give different team permissions per workspace
- ❌ **Shared state locking**: All workspaces compete for same DynamoDB table

### Real-World Risk Example

```bash
# Developer working on production
$ pwd
/workspaces-example/one-instance    # Doesn't show which workspace!

$ terraform destroy
# ❌ DISASTER: Just destroyed production data!

# Why it happened:
# 1. Forgot which workspace was selected
# 2. No file system indication of which environment
# 3. Same credentials for all workspaces
# 4. No access control to prevent it
```

### Comparison: Logical vs Physical Isolation

| Aspect | Logical (Workspaces) | Physical (File Layout) |
|--------|---|---|
| **Backend** | Single bucket/container | Multiple buckets/containers |
| **Configuration** | Same code for all | Different code per environment |
| **Credentials** | Shared (all workspaces) | Can be different per environment |
| **Visibility** | Hidden (workspace names invisible) | Visible (folder structure shows environment) |
| **Error Risk** | High (forgot workspace) | Low (must navigate to folder) |
| **Recommended For** | Ephemeral environments | Production/persistent environments |

---

## Architecture Diagram

```mermaid
graph TB
    subgraph "Terraform Configuration"
        CODE["Single Codebase<br/>main.tf<br/>Conditional Logic:<br/>if workspace==default<br/>  use t2.medium<br/>else<br/>  use t2.micro"]
    end

    subgraph "Workspaces with S3 Backend"
        DEFAULT["Workspace: default<br/>State: s3://bucket/env:/default/terraform.tfstate<br/>Instance: t2.medium<br/>Purpose: Production"]
        DEV["Workspace: dev<br/>State: s3://bucket/env:/dev/terraform.tfstate<br/>Instance: t2.micro<br/>Purpose: Development"]
        STAGING["Workspace: staging<br/>State: s3://bucket/env:/staging/terraform.tfstate<br/>Instance: t2.micro<br/>Purpose: Staging"]
    end

    subgraph "AWS EC2 Resources"
        EC2_PROD["EC2 Instance<br/>prod-server<br/>t2.medium<br/>1 vCPU, 4GB RAM"]
        EC2_DEV["EC2 Instance<br/>dev-server<br/>t2.micro<br/>1 vCPU, 1GB RAM"]
        EC2_STAGING["EC2 Instance<br/>staging-server<br/>t2.micro<br/>1 vCPU, 1GB RAM"]
    end

    CODE -->|"Deploys with<br/>default workspace"| DEFAULT
    CODE -->|"Deploys with<br/>dev workspace"| DEV
    CODE -->|"Deploys with<br/>staging workspace"| STAGING

    DEFAULT --> EC2_PROD
    DEV --> EC2_DEV
    STAGING --> EC2_STAGING
```

## Workspace Management Commands

### View Workspaces

```bash
# List all workspaces
terraform workspace list

# Example output:
# default
# * dev
#   staging
#   prod

# The asterisk (*) shows the current active workspace
```

### Create Workspaces

```bash
# Create a new workspace
terraform workspace new dev

# Create multiple workspaces
terraform workspace new staging
terraform workspace new prod
```

### Switch Workspaces

```bash
# Switch to a different workspace
terraform workspace select dev

# Verify you're in the right workspace
terraform workspace show
# Output: dev
```

### Delete Workspaces

```bash
# First, destroy resources in the workspace
terraform workspace select dev
terraform destroy

# Then delete the workspace
terraform workspace delete dev
```

## State File Organization

When using S3 backend with workspaces, the directory structure is:

```bash
s3://terraform-state-bucket/
├── env:/
│   ├── default/
│   │   └── terraform.tfstate        # Production state
│   ├── dev/
│   │   └── terraform.tfstate        # Development state
│   ├── staging/
│   │   └── terraform.tfstate        # Staging state
│   └── prod/
│       └── terraform.tfstate        # Production state
```

Each workspace has:

- **Separate state file**: No risk of cross-contamination
- **Version history**: S3 versioning tracks all changes
- **State locking**: DynamoDB prevents concurrent operations
- **Encryption**: AES256 protects sensitive data

## Workspace-Based Configuration

### Using terraform.workspace in Resources

The `terraform.workspace` built-in variable allows conditional resource configuration:

```hcl
# Example 1: Instance type by environment
instance_type = terraform.workspace == "default" ? "t2.large" : "t2.micro"

# Example 2: Replica count by environment
desired_capacity = terraform.workspace == "prod" ? 10 : 2

# Example 3: Backup retention by environment
backup_retention = terraform.workspace == "prod" ? 30 : 7

# Example 4: Logging level by environment
log_level = terraform.workspace == "dev" ? "DEBUG" : "INFO"
```

### Using Variables with Workspaces

You can also use `.tfvars` files per workspace:

```bash
# Create workspace-specific variable files
terraform.dev.tfvars
terraform.staging.tfvars
terraform.prod.tfvars
```

Then apply with:

```bash
terraform workspace select dev
terraform apply -var-file="terraform.dev.tfvars"
```

## Advantages of Workspaces

### 1. Code Reusability

- Write configuration once
- Deploy to multiple environments
- Reduce code duplication

### 2. Environment Isolation

- Each workspace has its own state
- Destroy dev without affecting prod
- Safe testing and experimentation

### 3. Cost Management

- Use smaller instances in dev/staging
- Use larger instances in production
- Scale based on environment needs

### 4. Consistency

- Same infrastructure code everywhere
- Reduces configuration drift
- Easier to reproduce issues

## Limitations and Considerations

### When NOT to Use Workspaces

❌ **Not recommended for**:

- Complex multi-environment setups (use separate directories instead)
- Significant regional differences (use different providers)
- Different cloud providers per environment
- Completely different infrastructure

### Best Practices

✅ **Do**:

- Use for small environment variations
- Keep workspace names simple: dev, staging, prod
- Document workspace-specific configuration
- Use state locking (DynamoDB)
- Enable versioning (S3)

❌ **Don't**:

- Create too many workspaces (harder to manage)
- Use for CI/CD without automation
- Store secrets in state files
- Mix workspaces with -var-file without careful management

## Advanced: Using Workspaces with Modules

When using modules with workspaces:

```hcl
module "web_server" {
  source = "../modules/web-server"

  instance_type = terraform.workspace == "prod" ? "c5.xlarge" : "t2.micro"
  environment   = terraform.workspace

  # Use workspace name as a tag
  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

output "server_info" {
  value = "Created ${terraform.workspace} server: ${module.web_server.instance_id}"
}
```

## Cost Comparison

### Monthly Cost (On-Demand, us-east-2)

| Workspace | Instance | vCPU | RAM | Cost/Hour | Cost/Month |
|-----------|----------|------|-----|-----------|------------|
| default (prod) | t2.medium | 2 | 4 GB | $0.0464 | $33.41 |
| dev | t2.micro | 1 | 1 GB | $0.0116 | $8.35 |
| staging | t2.micro | 1 | 1 GB | $0.0116 | $8.35 |
| **Total (3 workspaces)** | | | | | **$50.11** |

## Real-World Example: Multi-Environment Deployment

```bash
# 1. Initialize Terraform
terraform init

# 2. Create development environment
terraform workspace new dev
terraform apply -auto-approve

# 3. Create staging environment
terraform workspace new staging
terraform apply -auto-approve

# 4. Create production environment
terraform workspace new prod
terraform apply

# 5. Verify all environments
terraform workspace list

# 6. Check production instance size
terraform workspace select prod
terraform show

# 7. Clean up development environment
terraform workspace select dev
terraform destroy -auto-approve
terraform workspace delete dev
```

## Troubleshooting

### Issue: "Workspace not found"

```bash
# Create the workspace if it doesn't exist
terraform workspace new workspace-name

# Or list available workspaces
terraform workspace list
```

### Issue: "Resource already exists"

This typically happens when:

1. Workspace state is not properly isolated
2. Resource names conflict across workspaces

Solution:

```bash
# Use workspace name in resource naming
name = "${terraform.workspace}-resource"
```

### Issue: "State lock error"

```bash
# Check locked workspaces
aws dynamodb scan --table-name terraform_locks

# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>
```

## Drawbacks of Workspaces: When NOT to Use Them

Terraform workspaces can be a great way to quickly spin up and tear down different versions of your code, but they have several important drawbacks that make them unsuitable for isolating environments in many scenarios:

### 1. Shared Backend Access

The state files for all of your workspaces are stored in the same backend (e.g., the same S3 bucket). This means:

- You use the same authentication and access controls for all the workspaces
- No access control separation between environments (e.g., staging vs. production)
- One compromised credential exposes all environments
- **This is one major reason workspaces are unsuitable for isolating environments**

### 2. Lack of Visibility

Workspaces are not visible in the code or on the terminal unless you run `terraform workspace` commands:

- A module deployed in one workspace looks exactly the same as one deployed in 10 workspaces
- You must remember to check which workspace you're in before running commands
- Makes maintenance more difficult
- Hard to understand your infrastructure at a glance

### 3. Error-Prone Operations

Combining the two previous drawbacks results in a high-risk operational situation:

- **Easy to forget your workspace**: It's simple to forget which workspace you're in
- **Easy to destroy the wrong environment**: Running `terraform destroy` in the wrong workspace (e.g., accidentally destroying production instead of staging) is a real risk
- **Limited safeguards**: With the same authentication mechanism for all workspaces, you have no other layers of defense

**Example Risk Scenario**:
```bash
# You think you're in staging...
terraform destroy

# But you're actually in production!
# Your production infrastructure is now gone.
```

### 4. Not Suitable for Environment Isolation

**Due to these drawbacks, workspaces are NOT a suitable mechanism for isolating one environment from another** (e.g., isolating staging from production).

### When to Use Workspaces

Workspaces work well when:

- You have **small, similar environments**
- You don't need strong access control isolation
- You have **low-risk infrastructure** (e.g., testing, development)
- You want to **quickly experiment** with changes
- The infrastructure variations are **minimal**

### When NOT to Use Workspaces

❌ Do NOT use workspaces for:

- **Production environment isolation** (from staging, dev, etc.)
- **Different access control requirements** per environment
- **Compliance-sensitive environments** (PCI, HIPAA, SOC 2)
- **Multi-team setups** where teams shouldn't access each other's infrastructure
- **Significant infrastructure differences** between environments

### Better Alternative: File Layout

To achieve proper isolation between environments, **use file layout instead of workspaces**. Create separate directory structures for each environment:

```text
infrastructure/
├── global/
│   └── s3/                    # Shared backend
├── prod/
│   ├── data-stores/
│   ├── services/
│   └── terraform.tfstate      # Production state
├── staging/
│   ├── data-stores/
│   ├── services/
│   └── terraform.tfstate      # Staging state
└── dev/
    ├── data-stores/
    ├── services/
    └── terraform.tfstate      # Development state
```

Benefits of file layout:

- ✅ Separate backends per environment (different S3 buckets, different credentials)
- ✅ Clear visibility in code and file system
- ✅ Different access controls per environment
- ✅ Safe environment isolation
- ✅ Suitable for production deployments

See the `file-layout-example` directory for a complete example using this approach.

### Cleanup Instructions

Before moving on, make sure to clean up the EC2 instances you deployed by running:

```bash
# List all workspaces to see what exists
terraform workspace list

# For each workspace (except default if empty):
terraform workspace select <workspace-name>
terraform destroy -auto-approve

# Then delete the workspace
terraform workspace delete <workspace-name>

# Finally, destroy and clean up the default workspace
terraform workspace select default
terraform destroy -auto-approve
```

## Pre-requisites

- You must have [Terraform](https://www.terraform.io/) installed on your computer.
- You must have an [Amazon Web Services (AWS) account](http://aws.amazon.com/).
- AWS credentials configured in environment or `~/.aws/credentials`
- S3 bucket and DynamoDB table for remote state (from global/s3 example)

Please note that this code was written for Terraform 1.x.

## Quick start

**Please note that this example will deploy real resources into your AWS account. We have made every effort to ensure
all the resources qualify for the [AWS Free Tier](https://aws.amazon.com/free/), but we are not responsible for any
charges you may incur.**

Configure your [AWS access
keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as
environment variables:

```bash
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

### Step 1: Initialize Terraform

```bash
terraform init
```

This creates the initial `default` workspace.

### Step 2: Deploy to Default Workspace (Production)

```bash
terraform apply
```

This deploys a **t2.medium** instance to production.

### Step 3: Create and Deploy to Dev Workspace

```bash
terraform workspace new dev
terraform apply
```

This creates a **t2.micro** instance in the dev workspace, keeping prod separate.

### Step 4: Create Additional Workspaces

```bash
terraform workspace new staging
terraform workspace select staging
terraform apply
```

### Step 5: View All Workspaces and Their Resources

```bash
# List all workspaces
terraform workspace list

# Switch between workspaces to view resources
terraform workspace select prod
terraform state list

terraform workspace select dev
terraform state list
```

### Step 6: Clean Up

```bash
# Destroy resources in current workspace
terraform destroy

# Delete workspace
terraform workspace delete <workspace-name>

# Switch to default and destroy
terraform workspace select default
terraform destroy
```

### Step 7: Clean Everything

```bash
# Delete all workspaces except default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod

# Delete default workspace resources
terraform workspace select default
terraform destroy
```
