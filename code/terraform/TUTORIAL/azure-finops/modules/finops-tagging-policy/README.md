# FinOps Tagging Policy Module

This Terraform module creates Azure Policy definitions and assignments to enforce mandatory tags on resources for cost allocation and governance.

## Features

- **Multiple Required Tags**: Enforce multiple mandatory tags (CostCenter, Owner, Environment, etc.)
- **Flexible Policy Effects**: Audit, Deny, or Modify (auto-add tags)
- **Multiple Scopes**: Subscription, Management Group, or Resource Group level
- **Tag Value Validation**: Optional validation of allowed tag values
- **Resource Selectors**: Filter which resources the policy applies to

## Value Proposition

- **Cost Allocation**: Ensures all resources are trackable for cost attribution
- **Governance Guardrails**: Prevents deployments without proper ownership and cost center attribution
- **Compliance**: Automated enforcement of organizational tagging standards
- **Showback/Chargeback**: Enables accurate cost allocation to teams and projects

## Usage

### Basic Example: Audit Mode (Recommended for Initial Deployment)

```hcl
module "tagging_policy" {
  source = "./modules/finops-tagging-policy"

  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  policy_effect   = "Audit"  # Start with Audit, then switch to Deny after compliance

  required_tags = [
    {
      name         = "CostCenter"
      display_name = "Cost Center"
      description  = "Cost center or budget code"
    },
    {
      name         = "Owner"
      display_name = "Owner"
      description  = "Team or individual responsible"
    },
    {
      name         = "Environment"
      display_name = "Environment"
      description  = "Environment name"
      allowed_values = ["dev", "staging", "prod"]
    }
  ]
}
```

### Advanced Example: Deny Mode with Custom Tags

```hcl
module "tagging_policy" {
  source = "./modules/finops-tagging-policy"

  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  policy_effect   = "Deny"  # Block deployments without required tags
  policy_name     = "enterprise-required-tags"
  
  required_tags = [
    {
      name         = "CostCenter"
      display_name = "Cost Center"
      description  = "Cost center code (e.g., IT-001, ENG-002)"
    },
    {
      name         = "Owner"
      display_name = "Owner"
      description  = "Email or team name of resource owner"
    },
    {
      name         = "Environment"
      display_name = "Environment"
      description  = "Deployment environment"
      allowed_values = ["dev", "staging", "prod", "test"]
    },
    {
      name         = "Project"
      display_name = "Project"
      description  = "Project or application name"
    },
    {
      name         = "DataClassification"
      display_name = "Data Classification"
      description  = "Data sensitivity level"
      allowed_values = ["Public", "Internal", "Confidential", "Restricted"]
    }
  ]

  non_compliance_message = "Resources must include all required tags: CostCenter, Owner, Environment, Project, DataClassification"
  
  tags = {
    ManagedBy = "Terraform"
    Purpose   = "FinOps-Governance"
  }
}
```

### Modify Effect: Auto-Add Tags

```hcl
module "tagging_policy" {
  source = "./modules/finops-tagging-policy"

  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  policy_effect   = "Modify"  # Automatically add tags if missing
  
  required_tags = [
    {
      name         = "CostCenter"
      default_value = "UNASSIGNED"  # Auto-add this value if tag is missing
    },
    {
      name         = "Environment"
      default_value = "dev"
    }
  ]

  assignment_location = "eastus"  # Required for Modify effect
}
```

### Management Group Scope

```hcl
module "tagging_policy" {
  source = "./modules/finops-tagging-policy"

  management_group_id = "/providers/Microsoft.Management/managementGroups/MyManagementGroup"
  assignment_scope    = "management_group"
  policy_effect       = "Audit"
  
  required_tags = [
    {
      name = "CostCenter"
    },
    {
      name = "Owner"
    }
  ]
}
```

### Resource Group Scope

```hcl
module "tagging_policy" {
  source = "./modules/finops-tagging-policy"

  resource_group_id = "/subscriptions/.../resourceGroups/rg-production"
  assignment_scope   = "resource_group"
  policy_effect      = "Deny"
  
  required_tags = [
    {
      name = "CostCenter"
    }
  ]
}
```

## Inputs

| Name | Type | Description | Default | Required |
|------|------|-------------|---------|----------|
| `subscription_id` | `string` | Subscription ID (if scope is subscription) | `null` | no |
| `management_group_id` | `string` | Management Group ID (if scope is management_group) | `null` | no |
| `resource_group_id` | `string` | Resource Group ID (if scope is resource_group) | `null` | no |
| `assignment_scope` | `string` | Scope of assignment (subscription/management_group/resource_group) | `"subscription"` | no |
| `required_tags` | `list(object)` | List of required tags with configuration | See defaults | no |
| `policy_name` | `string` | Name of policy definition | `"finops-required-tags"` | no |
| `policy_display_name` | `string` | Display name of policy | `"FinOps: Require mandatory tags"` | no |
| `policy_description` | `string` | Description of policy | See default | no |
| `policy_category` | `string` | Category of policy | `"FinOps"` | no |
| `policy_mode` | `string` | Mode of policy (Indexed/All/etc.) | `"Indexed"` | no |
| `policy_effect` | `string` | Effect (Audit/Deny/Modify/Disabled) | `"Audit"` | no |
| `assignment_name` | `string` | Name of assignment | `null` | no |
| `assignment_location` | `string` | Location for assignment | `"eastus"` | no |
| `non_compliance_message` | `string` | Custom non-compliance message | `null` | no |
| `enforcement_mode` | `string` | Enforcement mode (Default/DoNotEnforce) | `"Default"` | no |
| `resource_selectors` | `object` | Optional resource selectors | `null` | no |
| `tags` | `map(string)` | Tags for policy resources | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `policy_definition_id` | The ID of the Policy Definition |
| `policy_definition_name` | The name of the Policy Definition |
| `policy_assignment_id` | The ID of the Policy Assignment |
| `policy_assignment_name` | The name of the Policy Assignment |
| `required_tags` | List of required tag names |

## Policy Effects

### Audit (Recommended for Initial Deployment)
- **Use Case**: Identify resources missing required tags without blocking deployments
- **Best Practice**: Start with Audit mode, review compliance, then switch to Deny
- **Timeline**: Use for first 30-60 days

### Deny (Production Enforcement)
- **Use Case**: Block deployments that don't include required tags
- **Best Practice**: Enable after achieving high compliance in Audit mode
- **Timeline**: Enable after compliance review

### Modify (Auto-Remediation)
- **Use Case**: Automatically add default tag values to non-compliant resources
- **Best Practice**: Use for tags with safe default values (e.g., Environment=dev)
- **Note**: Requires SystemAssigned identity and assignment location

### Disabled
- **Use Case**: Temporarily disable policy without removing assignment
- **Best Practice**: Use for troubleshooting or policy updates

## Best Practices

1. **Start with Audit Mode**: Begin with Audit to identify non-compliant resources before enforcing Deny
2. **Gradual Rollout**: Apply to resource groups first, then subscriptions, then management groups
3. **Tag Value Validation**: Use `allowed_values` for tags with limited options (Environment, DataClassification)
4. **Clear Messages**: Provide clear non-compliance messages explaining what tags are required
5. **Documentation**: Document required tags and their purposes in your organization's wiki
6. **Regular Reviews**: Review policy compliance monthly and adjust as needed

## Implementation Roadmap

### Phase 1: Visibility (Days 1-30)
- Deploy policy in **Audit** mode
- Review compliance reports weekly
- Communicate tagging requirements to teams

### Phase 2: Enforcement (Days 31-60)
- Switch to **Deny** mode for new resources
- Remediate existing non-compliant resources
- Achieve 90%+ compliance

### Phase 3: Optimization (Days 61+)
- Refine tag values and allowed values
- Add additional required tags as needed
- Integrate with cost allocation tools

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Related Modules

- `finops-budget-guardrails` - Automated budget alerts
- `finops-cost-export` - Export detailed billing data
- `finops-resource-scheduler` - Auto-shutdown based on tags

## License

This module is part of the Azure FinOps Terraform tutorial and is provided as-is for educational purposes.
