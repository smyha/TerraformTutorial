# Front Door Web Application Firewall (WAF)

This guide explains how to configure Web Application Firewall (WAF) in Azure Front Door using Terraform.

## Overview

Azure Front Door Premium includes advanced Web Application Firewall capabilities to protect applications from common web vulnerabilities. WAF operates at the edge network, inspecting requests before they reach your backends.

## WAF Policy Creation

### Basic WAF Policy

```hcl
resource "azurerm_frontdoor_firewall_policy" "main" {
  name                = "waf-policy"
  resource_group_name = azurerm_resource_group.fd.name
  enabled             = true
  mode                = "Prevention"  # or "Detection"
}
```

## WAF Modes

### Detection Mode

Detection mode logs threats but doesn't block requests. Useful for testing and monitoring.

```hcl
resource "azurerm_frontdoor_firewall_policy" "detection" {
  name                = "waf-policy-detection"
  resource_group_name = azurerm_resource_group.fd.name
  enabled             = true
  mode                = "Detection"  # Log threats, don't block
}
```

### Prevention Mode

Prevention mode blocks requests that match threat patterns. Recommended for production.

```hcl
resource "azurerm_frontdoor_firewall_policy" "prevention" {
  name                = "waf-policy-prevention"
  resource_group_name = azurerm_resource_group.fd.name
  enabled             = true
  mode                = "Prevention"  # Block threats
}
```

## WAF Policy Configuration

### Custom Rules

```hcl
resource "azurerm_frontdoor_firewall_policy" "main" {
  name                = "waf-policy"
  resource_group_name = azurerm_resource_group.fd.name
  enabled             = true
  mode                = "Prevention"

  # Custom Rule: Rate Limiting
  custom_rule {
    name                           = "RateLimitRule"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 100
    type                           = "RateLimitRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RequestUri"
      operator           = "Contains"
      match_values       = ["/api/"]
      transforms         = ["Lowercase"]
    }
  }

  # Custom Rule: IP Blocking
  custom_rule {
    name     = "BlockIPRule"
    enabled  = true
    priority = 2
    type     = "MatchRule"
    action   = "Block"

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "IPMatch"
      match_values   = ["192.168.1.0/24", "10.0.0.0/8"]
    }
  }

  # Custom Rule: Geo-filtering
  custom_rule {
    name     = "GeoBlockRule"
    enabled  = true
    priority = 3
    type     = "MatchRule"
    action   = "Block"

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "GeoMatch"
      match_values   = ["CN", "RU"]  # Block China and Russia
    }
  }
}
```

## Managed Rules

### OWASP Core Rule Set

```hcl
resource "azurerm_frontdoor_firewall_policy" "main" {
  name                = "waf-policy"
  resource_group_name = azurerm_resource_group.fd.name
  enabled             = true
  mode                = "Prevention"

  # Managed Rule Set: OWASP
  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"

    # Disable specific rule groups
    exclusion {
      match_variable = "RequestHeaderNames"
      operator       = "Equals"
      selector       = "User-Agent"
    }
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }
}
```

## WAF Policy Association

### Associate WAF with Frontend Endpoint

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  # Frontend Endpoint with WAF
  frontend_endpoint {
    name                                    = "www-endpoint"
    host_name                               = "www.example.com"
    web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.main.id
  }

  # ... other configuration ...
}
```

## Complete WAF Example

```hcl
resource "azurerm_resource_group" "fd" {
  name     = "rg-front-door"
  location = "global"
}

# WAF Policy
resource "azurerm_frontdoor_firewall_policy" "main" {
  name                = "waf-policy"
  resource_group_name = azurerm_resource_group.fd.name
  enabled             = true
  mode                = "Prevention"
  redirect_url        = "https://www.example.com/blocked"

  # Custom Rule: Rate Limiting
  custom_rule {
    name                           = "RateLimitRule"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 100
    type                           = "RateLimitRule"
    action                         = "Block"

    match_condition {
      match_variable = "RequestUri"
      operator       = "Contains"
      match_values   = ["/api/"]
    }
  }

  # Custom Rule: Block Specific Paths
  custom_rule {
    name     = "BlockAdminPath"
    enabled  = true
    priority = 2
    type     = "MatchRule"
    action   = "Block"

    match_condition {
      match_variable = "RequestUri"
      operator       = "Contains"
      match_values   = ["/admin/", "/wp-admin/"]
    }
  }

  # Managed Rule: OWASP
  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  # Managed Rule: Bot Manager
  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Front Door with WAF
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name
  friendly_name       = "Global Application Front Door"
  load_balancer_enabled = true

  # Frontend Endpoint with WAF
  frontend_endpoint {
    name                                    = "www-endpoint"
    host_name                               = "www.example.com"
    web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.main.id
  }

  # ... backend pools, routing rules, etc. ...
}
```

## WAF Best Practices

1. **Use Prevention Mode**: Use Prevention mode for production
2. **Start with Detection**: Test WAF in Detection mode first
3. **Custom Rules**: Create custom rules for application-specific needs
4. **Rate Limiting**: Implement rate limiting for API endpoints
5. **Geo-filtering**: Use geo-filtering to block unwanted regions
6. **Monitor Logs**: Regularly review WAF logs for false positives
7. **Update Rules**: Keep managed rule sets updated

## Additional Resources

- [Front Door WAF Policy Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor_firewall_policy)
- [Front Door WAF Documentation](https://learn.microsoft.com/en-us/azure/frontdoor/waf-overview)
- [Front Door WAF Custom Rules](https://learn.microsoft.com/en-us/azure/frontdoor/waf-front-door-custom-rules)

