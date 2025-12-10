# Configuring Action Groups with Terraform

This guide explains how to configure action groups in Azure Monitor using Terraform.

## Overview

Action groups define how alerts are notified and what actions are taken when alerts are triggered. They can send notifications via email, SMS, webhooks, and more.

## Basic Action Group

### Minimal Configuration

```hcl
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "alerts"

  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
  }
}
```

## Action Group Parameters

### Basic Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Name of the action group |
| `resource_group_name` | string | Yes | Resource group name |
| `short_name` | string | Yes | Short name (max 12 characters) |
| `enabled` | bool | No | Enable/disable action group (default: true) |

## Receiver Types

### Email Receiver

```hcl
email_receiver {
  name          = "admin"
  email_address = "admin@example.com"
  use_common_alert_schema = true
}
```

### SMS Receiver

```hcl
sms_receiver {
  name         = "admin"
  country_code = "1"
  phone_number = "5551234567"
}
```

### Webhook Receiver

```hcl
webhook_receiver {
  name                    = "webhook"
  service_uri             = "https://example.com/webhook"
  use_common_alert_schema = true
}
```

### Azure App Push Receiver

```hcl
azure_app_push_receiver {
  name          = "app-push"
  email_address = "admin@example.com"
}
```

### Voice Receiver

```hcl
voice_receiver {
  name         = "voice"
  country_code = "1"
  phone_number = "5551234567"
}
```

### Logic App Receiver

```hcl
logic_app_receiver {
  name                    = "logic-app"
  resource_id             = azurerm_logic_app_workflow.main.id
  callback_url            = "https://example.com/callback"
  use_common_alert_schema = true
}
```

### Azure Function Receiver

```hcl
azure_function_receiver {
  name                     = "function"
  function_app_resource_id = azurerm_function_app.main.id
  function_name            = "AlertHandler"
  http_trigger_url         = "https://example.com/trigger"
  use_common_alert_schema = true
}
```

## Complete Example

```hcl
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-production-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "prod-alerts"
  enabled             = true

  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
    use_common_alert_schema = true
  }

  email_receiver {
    name          = "team"
    email_address = "team@example.com"
  }

  sms_receiver {
    name         = "oncall"
    country_code = "1"
    phone_number = "5551234567"
  }

  webhook_receiver {
    name                    = "slack"
    service_uri             = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    use_common_alert_schema = true
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Best Practices

1. **Multiple Receivers**: Use multiple notification channels for redundancy
2. **Common Alert Schema**: Enable common alert schema for consistent formatting
3. **Short Names**: Keep short names concise and meaningful
4. **Testing**: Test all notification channels
5. **Documentation**: Document action group purposes and receivers

