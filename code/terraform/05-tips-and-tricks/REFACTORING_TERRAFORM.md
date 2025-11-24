# Refactoring in Terraform: Dangers and Solutions

## Introduction

Refactoring in Terraform requires special care. Unlike traditional programming languages where renaming variables or functions is trivial, in Terraform these changes can cause **downtime** and **resource loss**.

## The Problem: Dangerous Refactoring

### Problem Diagram

```mermaid
graph TD
    A[Variable/Resource Name Change] --> B{Terraform detects change}
    B --> C[Plan shows: DELETE + CREATE]
    C --> D{Critical resource?}
    D -->|Yes| E[❌ DOWNTIME]
    D -->|No| F[⚠️ Possible data loss]
    
    E --> G[ALB deleted]
    E --> H[Security Group deleted]
    G --> I[No traffic routing]
    H --> J[Servers reject traffic]
    
    style E fill:#ff6b6b
    style F fill:#ffd93d
    style I fill:#ff6b6b
    style J fill:#ff6b6b
```

### Common Cases of Dangerous Refactoring

#### 1. Renaming Resource Variables

**Problematic Example:**

```hcl
# BEFORE: variable cluster_name = "foo"
# AFTER: variable cluster_name = "bar"

resource "aws_lb" "example" {
  name = var.cluster_name  # Changes from "foo" to "bar"
  # ...
}
```

**Consequence:** Terraform deletes the ALB "foo" and creates a new one "bar", causing downtime.

#### 2. Renaming Resource Identifiers

**Problematic Example:**

```hcl
# BEFORE
resource "aws_security_group" "instance" {
  # ...
}

# AFTER
resource "aws_security_group" "cluster_instance" {
  # ...
}
```

**Consequence:** Terraform interprets this as deleting `instance` and creating `cluster_instance`, causing downtime.

#### 3. Changing Immutable Parameters

Many resources have immutable parameters. If you change them, Terraform must delete and recreate the resource.

## Safe Refactoring Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant TF as Terraform Plan
    participant State as Terraform State
    participant AWS as AWS Cloud
    
    Dev->>TF: Code change (refactor)
    TF->>State: Compare code vs state
    State->>TF: Detects identifier change
    TF->>Dev: ⚠️ Plan shows DELETE + CREATE
    
    alt Without moved block
        Dev->>TF: terraform apply
        TF->>AWS: DELETE old resource
        AWS-->>Dev: ❌ DOWNTIME
        TF->>AWS: CREATE new resource
    else With moved block
        Dev->>TF: Add moved block
        TF->>State: Update reference
        TF->>Dev: ✅ Plan shows 0 changes
        Dev->>TF: terraform apply
        TF->>State: Only update state
        AWS-->>Dev: ✅ No changes in AWS
    end
```

## Solutions

### 1. Use `moved` Blocks (Terraform 1.1+)

**Advantage:** Automatic, documented in code, versioned.

```mermaid
graph LR
    A[Old Code] -->|Refactor| B[New Code]
    B --> C[moved block]
    C --> D[Terraform detects]
    D --> E[Updates state automatically]
    E --> F[✅ No changes in AWS]
    
    style F fill:#51cf66
    style C fill:#339af0
```

**Example:**

```hcl
# Renamed resource
resource "aws_security_group" "cluster_instance" {
  name = var.security_group_name
}

# moved block to automatically update state
moved {
  from = aws_security_group.instance
  to   = aws_security_group.cluster_instance
}
```

### 2. Use `terraform state mv` (Manual)

**Advantage:** Works in versions prior to Terraform 1.1.

**Disadvantage:** Requires manual execution, error-prone.

```mermaid
graph TD
    A[Identifier change] --> B[terraform state mv]
    B --> C[Manually update state]
    C --> D[terraform plan]
    D --> E{Shows changes?}
    E -->|Yes| F[❌ Error in mv]
    E -->|No| G[✅ Refactor successful]
    
    style G fill:#51cf66
    style F fill:#ff6b6b
```

**Command:**

```bash
terraform state mv \
  aws_security_group.instance \
  aws_security_group.cluster_instance
```

## Method Comparison

```mermaid
graph TB
    subgraph "Method 1: moved blocks"
        A1[✅ Automatic] 
        A2[✅ Documented in code]
        A3[✅ Versioned in Git]
        A4[✅ Requires Terraform 1.1+]
    end
    
    subgraph "Method 2: terraform state mv"
        B1[✅ Works in older versions]
        B2[❌ Manual]
        B3[❌ Error-prone]
        B4[❌ Not documented in code]
    end
    
    style A1 fill:#51cf66
    style A2 fill:#51cf66
    style A3 fill:#51cf66
    style A4 fill:#ffd93d
    style B1 fill:#51cf66
    style B2 fill:#ff6b6b
    style B3 fill:#ff6b6b
    style B4 fill:#ff6b6b
```

## Best Practices

### 1. Always Use `terraform plan`

```mermaid
flowchart TD
    A[Code change] --> B[terraform plan]
    B --> C{Shows DELETE?}
    C -->|Yes| D[⚠️ DANGER]
    C -->|No| E[✅ Safe]
    D --> F[Review if intentional]
    F --> G{Is intentional?}
    G -->|No| H[Add moved block]
    G -->|Yes| I[Consider create_before_destroy]
    
    style D fill:#ffd93d
    style E fill:#51cf66
```

### 2. Use `create_before_destroy` When Necessary

If you really need to replace a resource, use `create_before_destroy`:

```hcl
lifecycle {
  create_before_destroy = true
}
```

**Flow:**

```mermaid
sequenceDiagram
    participant TF as Terraform
    participant AWS as AWS
    
    Note over TF,AWS: With create_before_destroy
    
    TF->>AWS: CREATE new resource
    AWS-->>TF: ✅ New resource active
    TF->>AWS: DELETE old resource
    
    Note over TF,AWS: No downtime
```

### 3. Check Resource Documentation

Many parameters are immutable. Always check the documentation before changing parameters.

### 4. Refactor in Steps

```mermaid
graph LR
    A[Step 1: Add new resource] --> B[Step 2: Add moved block]
    B --> C[Step 3: terraform apply]
    C --> D[Step 4: Remove old code]
    D --> E[Step 5: terraform apply]
    
    style A fill:#339af0
    style B fill:#339af0
    style C fill:#51cf66
    style D fill:#339af0
    style E fill:#51cf66
```

## Special Cases

### Changes Requiring Special Attention

```mermaid
mindmap
  root((Dangerous<br/>Changes))
    Rename identifiers
      Resources
      Modules
    Change immutable parameters
      name in resources
      region in some resources
    Add count/for_each
      To existing resources
      To existing modules
    Split modules
      One module → multiple modules
```

## Summary: Safe Refactoring Checklist

```mermaid
graph TD
    A[Start refactoring] --> B[1. terraform plan]
    B --> C{Shows DELETE?}
    C -->|Yes| D[2. Is intentional?]
    C -->|No| E[✅ Safe refactor]
    
    D -->|No| F[3. Add moved block]
    D -->|Yes| G[3. Consider create_before_destroy]
    
    F --> H[4. terraform plan]
    G --> H
    H --> I{Plan shows 0 changes?}
    I -->|Yes| J[✅ Ready for apply]
    I -->|No| K[❌ Review moved block]
    
    style E fill:#51cf66
    style J fill:#51cf66
    style K fill:#ff6b6b
```

## Conclusion

Refactoring in Terraform requires:

1. ✅ **Always use `terraform plan`** before applying changes
2. ✅ **Use `moved` blocks** for identifier refactoring
3. ✅ **Check documentation** for immutable parameters
4. ✅ **Consider `create_before_destroy`** when necessary to replace resources
5. ✅ **Refactor in steps** to minimize risks

Remember: **Terraform is declarative, but code changes can have real consequences on infrastructure.**
