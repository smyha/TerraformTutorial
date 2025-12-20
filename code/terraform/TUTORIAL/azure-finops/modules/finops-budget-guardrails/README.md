# FinOps Budget Guardrails Module

This Terraform module creates automated budget alerts for Azure resource groups or subscriptions, enabling proactive cost management and decentralized accountability.

## Features

- **Multi-Scope Support**: Resource group or subscription-level budgets
- **Flexible Notifications**: Email, SMS, Webhook, and Azure Function receivers
- **Configurable Thresholds**: Customizable alert thresholds (default: 50%, 80%, 100%)
- **Forecasted Alerts**: Early warning based on forecasted spending
- **Enterprise-Ready**: Supports integration with centralized Action Group modules
- **Tag Filtering**: Optional filtering by resource tags

## Value Proposition

- **Decentralized Ownership**: Teams receive alerts about their spending automatically
- **Proactive Management**: Early warnings at 50% and 80% prevent budget overruns
- **Safety Net**: 100% threshold alerts prevent unexpected charges
- **Forecasted Alerts**: Predict future spending based on current trends

## Usage

### Basic Example: Resource Group Budget

```hcl
module "budget" {
  source = "./modules/finops-budget-guardrails"

  resource_group_name = "rg-production"
  resource_group_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-production"
  budget_amount       = 5000
  location            = "eastus"

  # Simple email notification
  email_receivers = [
    {
      name          = "finops-team"
      email_address = "finops@company.com"
    }
  ]

  tags = {
    CostCenter = "IT-Operations"
    Owner      = "FinOps-Team"
  }
}
```

### Advanced Example: Custom Notifications

```hcl
module "budget" {
  source = "./modules/finops-budget-guardrails"

  resource_group_name = "rg-production"
  resource_group_id   = "/subscriptions/.../resourceGroups/rg-production"
  budget_amount       = 10000
  time_grain         = "Monthly"
  budget_name         = "prod-monthly-budget"

  # Multiple email receivers
  email_receivers = [
    {
      name          = "team-lead"
      email_address = "team-lead@company.com"
    },
    {
      name          = "finops"
      email_address = "finops@company.com"
    }
  ]

  # Webhook for Slack/Teams integration
  webhook_receivers = [
    {
      name         = "slack-webhook"
      service_uri  = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
      use_common_alert_schema = true
      aad_auth = {
        object_id      = "00000000-0000-0000-0000-000000000000"
        identifier_uri = "api://slack-webhook"
        tenant_id      = "00000000-0000-0000-0000-000000000000"
      }
    }
  ]

  # Custom notification thresholds
  notifications = [
    {
      enabled        = true
      threshold      = 50.0
      threshold_type = "Actual"
      operator       = "EqualTo"
      contact_emails = []
    },
    {
      enabled        = true
      threshold      = 75.0
      threshold_type = "Actual"
      operator       = "EqualTo"
      contact_emails = []
    },
    {
      enabled        = true
      threshold      = 90.0
      threshold_type = "Forecasted"
      operator       = "GreaterThan"
      contact_emails = []
    },
    {
      enabled        = true
      threshold      = 100.0
      threshold_type = "Forecasted"
      operator       = "GreaterThan"
      contact_emails = []
    }
  ]

  tags = {
    Environment = "prod"
    CostCenter  = "IT-Operations"
  }
}
```

### Subscription-Level Budget

```hcl
module "subscription_budget" {
  source = "./modules/finops-budget-guardrails"

  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  budget_scope     = "subscription"
  budget_amount   = 50000
  time_grain      = "Monthly"
  budget_name     = "enterprise-monthly-budget"

  email_receivers = [
    {
      name          = "finance-team"
      email_address = "finance@company.com"
    }
  ]
}
```

### Using Existing Action Group (Data Source)

```hcl
# Reference existing action group via data source
data "azurerm_monitor_action_group" "existing" {
  name                = "shared-finops-alerts"
  resource_group_name = "rg-shared-services"
}

module "budget" {
  source = "./modules/finops-budget-guardrails"

  resource_group_id = "/subscriptions/.../resourceGroups/rg-production"
  budget_amount     = 5000

  # Use existing action group
  create_action_group         = false
  existing_action_group_id    = data.azurerm_monitor_action_group.existing.id
}
```

### Using Action Group from Module

```hcl
# If you have a centralized monitor/action-group module
module "shared_monitor" {
  source = "git::https://github.com/org/terraform-azurerm-monitor.git?ref=v1.0.0"
  
  action_group_name = "shared-finops-alerts"
  resource_group_name = "rg-shared-services"
  location = "eastus"
  # ... other action group configuration
}

module "budget" {
  source = "./modules/finops-budget-guardrails"

  resource_group_id = "/subscriptions/.../resourceGroups/rg-production"
  budget_amount     = 5000

  # Reference action group from module
  create_action_group         = false
  existing_action_group_id    = module.shared_monitor.action_group_id
}
```

## Inputs

| Name | Type | Description | Default | Required |
|------|------|-------------|---------|----------|
| `resource_group_id` | `string` | ID of the resource group for budget (if scope is resource_group) | `null` | no |
| `subscription_id` | `string` | ID of the subscription for budget (if scope is subscription) | `null` | no |
| `budget_scope` | `string` | Scope of budget (resource_group/subscription) | `"resource_group"` | no |
| `budget_name` | `string` | Name of the budget | `null` | no |
| `budget_amount` | `number` | Budget amount in subscription currency | - | yes |
| `time_grain` | `string` | Time covered by budget (Monthly/Quarterly/etc.) | `"Monthly"` | no |
| `time_period_start_date` | `string` | Start date in ISO 8601 format | `null` | no |
| `time_period_end_date` | `string` | End date in ISO 8601 format | `null` | no |
| `resource_group_name` | `string` | Name of RG for Action Group (if creating new) | `null` | no |
| `location` | `string` | Azure region for Action Group | `"global"` | no |
| `create_action_group` | `bool` | Whether to create a new Action Group | `true` | no |
| `existing_action_group_id` | `string` | ID of existing Action Group to use | `null` | no |
| `action_group_name` | `string` | Name of Action Group to create | `null` | no |
| `action_group_short_name` | `string` | Short name of Action Group (max 12 chars) | `"BudgetAlert"` | no |
| `email_receivers` | `list(object)` | List of email receivers | `[]` | no |
| `sms_receivers` | `list(object)` | List of SMS receivers | `[]` | no |
| `webhook_receivers` | `list(object)` | List of webhook receivers | `[]` | no |
| `azure_function_receivers` | `list(object)` | List of Azure Function receivers | `[]` | no |
| `notifications` | `list(object)` | List of budget notifications | See defaults | no |
| `filter_tags` | `map(list(string))` | Tags to filter budget by | `null` | no |
| `environment` | `string` | Environment name for tagging | `"prod"` | no |
| `tags` | `map(string)` | Map of tags to apply | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `budget_id` | The ID of the created Budget |
| `budget_name` | The name of the created Budget |
| `action_group_id` | The ID of the Action Group used for alerts |
| `action_group_name` | The name of the Action Group (if created) |

## Integration with Monitor Modules

This module supports three approaches for Action Group management:

### 1. Create New Action Group (Default)
The module creates a new Action Group with configurable receivers (email, SMS, webhook, etc.).

### 2. Use Existing Action Group (Data Source)
Reference an existing Action Group using a `data` block:

```hcl
data "azurerm_monitor_action_group" "existing" {
  name                = "shared-finops-alerts"
  resource_group_name = "rg-shared-services"
}
```

### 3. Use Action Group from Module (Recommended for Enterprise)
Reference an Action Group created by a centralized module:

```hcl
module "shared_monitor" {
  source = "git::https://github.com/org/terraform-azurerm-monitor.git"
  # ... configuration
}

module "budget" {
  source = "./modules/finops-budget-guardrails"
  existing_action_group_id = module.shared_monitor.action_group_id
  # ...
}
```

**Why use a centralized action group module?**
- **Consistency**: Standardized alerting across all teams
- **Maintenance**: Single source of truth for notification channels
- **Compliance**: Centralized audit trail and access control
- **Cost Optimization**: Shared resources reduce overhead

## Notification Thresholds

Default notifications are configured at:
- **50% (Actual)**: Early warning - spending is halfway to budget
- **80% (Actual)**: Critical warning - approaching budget limit
- **100% (Forecasted)**: Breach alert - forecasted to exceed budget

You can customize these thresholds and add additional notifications as needed.

## Best Practices

1. **Start with Resource Group Budgets**: Begin with team/service-level budgets before implementing subscription-level budgets
2. **Use Forecasted Alerts**: Enable forecasted alerts at 90-100% for early warning
3. **Multiple Notification Channels**: Combine email with webhooks (Slack/Teams) for better visibility
4. **Centralize Action Groups**: In enterprise environments, use shared action groups for consistency
5. **Tag Filtering**: Use filter_tags to create budgets for specific workloads or environments
6. **Quarterly Reviews**: Review and adjust budgets quarterly based on actual spending patterns

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Related Modules

- `finops-cost-export` - Export detailed billing data
- `finops-tagging-policy` - Enforce cost allocation tags
- `monitor` - Centralized monitoring and alerting

## License

This module is part of the Azure FinOps Terraform tutorial and is provided as-is for educational purposes.
