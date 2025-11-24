# Best Practices: Safe Refactoring in Terraform

## Table of Contents

1. [Fundamental Principles](#fundamental-principles)
2. [Refactoring Checklist](#refactoring-checklist)
3. [Common Cases and Solutions](#common-cases-and-solutions)
4. [Immutable Parameters](#immutable-parameters)
5. [Deployment Strategies](#deployment-strategies)

## Fundamental Principles

### 1. Terraform is Declarative, but Changes Have Real Consequences

```mermaid
graph LR
    A[Terraform Code] -->|terraform apply| B[Real Infrastructure]
    B -->|Changes| C[Service Impact]
    C -->|Poorly handled| D[❌ DOWNTIME]
    C -->|Well handled| E[✅ No Interruptions]
    
    style D fill:#ff6b6b
    style E fill:#51cf66
```

**Golden rule:** Every code change can result in real infrastructure changes. Always validate before applying.

### 2. Identifiers Are Identities

Terraform associates each resource identifier with a cloud provider ID:

```mermaid
graph TB
    A[aws_security_group.instance] -->|Maps to| B[sg-12345678 in AWS]
    C[Identifier change] -->|Without moved block| D[Terraform thinks:<br/>DELETE sg-12345678<br/>CREATE new SG]
    C -->|With moved block| E[Terraform updates:<br/>instance → cluster_instance<br/>Same sg-12345678]
    
    style D fill:#ff6b6b
    style E fill:#51cf66
```

### 3. Always Use `terraform plan`

```mermaid
flowchart TD
    A[Code change] --> B[terraform plan]
    B --> C{Shows DELETE?}
    C -->|Yes| D[⚠️ DANGER]
    C -->|No| E[✅ Review changes]
    D --> F{Is intentional?}
    F -->|No| G[Add moved block]
    F -->|Yes| H[Consider create_before_destroy]
    E --> I[terraform apply]
    G --> B
    H --> I
    
    style D fill:#ffd93d
    style E fill:#51cf66
    style G fill:#339af0
```

## Refactoring Checklist

### Before Refactoring

- [ ] **Run `terraform plan`** to see current state
- [ ] **Document the reason** for refactoring
- [ ] **Identify critical resources** that might be affected
- [ ] **Review dependencies** between resources
- [ ] **Check immutable parameters** in documentation

### During Refactoring

- [ ] **Make incremental changes** (not all at once)
- [ ] **Add `moved` blocks** for identifier renames
- [ ] **Run `terraform plan`** after each change
- [ ] **Verify no unexpected DELETEs**
- [ ] **Document changes** with code comments

### After Refactoring

- [ ] **Run final `terraform plan`** to confirm
- [ ] **Apply in staging first** if possible
- [ ] **Monitor during apply** in production
- [ ] **Verify services work** after the change
- [ ] **Update documentation** if necessary

## Common Cases and Solutions

### Case 1: Rename Resource Variable

**Problem:**
```hcl
# Before
variable "cluster_name" {
  default = "foo"
}

# After
variable "cluster_name" {
  default = "bar"  # ⚠️ DANGER
}
```

**Impact:**
```mermaid
graph LR
    A[cluster_name: foo] -->|Used in| B[ALB name]
    A -->|Used in| C[Security Group name]
    A -->|Used in| D[Target Group name]
    
    E[cluster_name: bar] -->|Change causes| F[DELETE all foo resources]
    F --> G[CREATE all bar resources]
    G --> H[❌ DOWNTIME]
    
    style H fill:#ff6b6b
```

**Solution:**
- Don't change the value after initial deployment
- If necessary, create new resources first
- Migrate gradually

### Case 2: Rename Resource Identifier

**Problem:**
```hcl
# Before
resource "aws_security_group" "instance" { }

# After
resource "aws_security_group" "cluster_instance" { }
```

**Solution:**
```hcl
resource "aws_security_group" "cluster_instance" { }

moved {
  from = aws_security_group.instance
  to   = aws_security_group.cluster_instance
}
```

### Case 3: Move Resource to Module

**Problem:**
```hcl
# Before: Resource in root
resource "aws_security_group" "instance" { }

# After: Resource in module
module "cluster" {
  source = "./modules/cluster"
}
```

**Solution:**
```hcl
module "cluster" {
  source = "./modules/cluster"
}

moved {
  from = aws_security_group.instance
  to   = module.cluster.aws_security_group.instance
}
```

### Case 4: Change from `count` to `for_each`

**Problem:**
```hcl
# Before
resource "aws_instance" "example" {
  count = 3
}

# After
resource "aws_instance" "example" {
  for_each = toset(["instance-1", "instance-2", "instance-3"])
}
```

**Solution:**
```hcl
resource "aws_instance" "example" {
  for_each = toset(["instance-1", "instance-2", "instance-3"])
}

moved {
  from = aws_instance.example[0]
  to   = aws_instance.example["instance-1"]
}

moved {
  from = aws_instance.example[1]
  to   = aws_instance.example["instance-2"]
}

moved {
  from = aws_instance.example[2]
  to   = aws_instance.example["instance-3"]
}
```

### Case 5: Add `count` or `for_each` to Existing Resource

**Problem:**
```hcl
# Before
resource "aws_security_group" "instance" { }

# After
resource "aws_security_group" "instance" {
  count = 2  # ⚠️ DANGER
}
```

**Impact:** Terraform will interpret this as deleting the single resource and creating multiple resources.

**Solution:**
```hcl
# Option 1: Rename first, then add count
resource "aws_security_group" "instances" {
  count = 2
}

moved {
  from = aws_security_group.instance
  to   = aws_security_group.instances[0]
}

# Option 2: Create new resources and delete old one after
```

## Immutable Parameters

### Common Resources with Immutable Parameters

```mermaid
mindmap
  root((Immutable<br/>Parameters))
    AWS Resources
      ALB name
      Security Group name
      Target Group name
      VPC ID in many resources
      Subnet IDs in some resources
    Database Resources
      Engine version
      Master username
      DB name
    Network Resources
      CIDR blocks
      Availability zones
```

### How to Identify Immutable Parameters

1. **Check official documentation** for the resource
2. **Run `terraform plan`** - will show if recreation is required
3. **Review Terraform error messages**

### Strategy for Changing Immutable Parameters

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant TF as Terraform
    participant AWS as AWS
    
    Note over Dev: Need to change immutable parameter
    
    Dev->>TF: terraform plan
    TF->>Dev: ⚠️ Forces replacement
    
    alt With create_before_destroy
        Dev->>TF: Add lifecycle block
        TF->>AWS: CREATE new resource
        AWS-->>Dev: ✅ New resource active
        TF->>AWS: DELETE old resource
        Note over Dev,AWS: No downtime
    else Without create_before_destroy
        TF->>AWS: DELETE old resource
        AWS-->>Dev: ❌ DOWNTIME
        TF->>AWS: CREATE new resource
    end
```

## Deployment Strategies

### 1. Create Before Destroy

**When to use:**
- Critical resources that cannot be offline
- Resources referenced by other active resources
- Load balancers, security groups, databases

**Example:**
```hcl
resource "aws_security_group" "instance" {
  # ...
  
  lifecycle {
    create_before_destroy = true
  }
}
```

**Flow:**
```mermaid
sequenceDiagram
    participant TF as Terraform
    participant AWS as AWS
    participant App as Application
    
    TF->>AWS: CREATE new resource
    AWS-->>App: ✅ New resource available
    App->>App: Migrate to new resource
    TF->>AWS: DELETE old resource
    
    Note over TF,App: No downtime
```

### 2. Blue-Green Deployment

For major changes, consider creating a completely new environment:

```mermaid
graph LR
    A[Blue Environment<br/>Active] -->|Create| B[Green Environment<br/>New]
    B -->|Validate| C{Works?}
    C -->|Yes| D[Switch traffic]
    C -->|No| E[Fix and repeat]
    D --> F[Delete Blue]
    
    style A fill:#339af0
    style B fill:#51cf66
    style D fill:#51cf66
```

### 3. Incremental Refactoring

```mermaid
graph TD
    A[Step 1: Add new resource] --> B[Step 2: Add moved block]
    B --> C[Step 3: terraform apply]
    C --> D[Step 4: Verify functionality]
    D --> E[Step 5: Remove old code]
    E --> F[Step 6: terraform apply]
    
    style A fill:#339af0
    style C fill:#51cf66
    style D fill:#ffd93d
    style F fill:#51cf66
```

## Summary: Golden Rules

```mermaid
mindmap
  root((Golden Rules<br/>Refactoring))
    Always Plan
      Run terraform plan first
      Review output carefully
      Look for unexpected DELETEs
    Use moved blocks
      For identifier renames
      For moving resources to modules
      For count/for_each changes
    Check immutables
      Consult documentation
      Review plan messages
      Consider create_before_destroy
    Refactor incrementally
      One change at a time
      Validate after each step
      Document changes
    Test first
      In staging/development
      Validate functionality
      Monitor during apply
```

## Conclusion

Refactoring in Terraform requires:

1. ✅ **Knowledge** of how Terraform handles state
2. ✅ **Care** when making seemingly simple changes
3. ✅ **Tools** like `moved` blocks and `create_before_destroy`
4. ✅ **Validation** constantly with `terraform plan`
5. ✅ **Documentation** of changes and decisions

**Remember:** In Terraform, a "simple" code change can have real consequences on infrastructure. Always validate before applying.
