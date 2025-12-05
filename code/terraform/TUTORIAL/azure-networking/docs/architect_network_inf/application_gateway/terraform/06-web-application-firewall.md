# Implementing Web Application Firewall with Terraform

## Overview

Web Application Firewall (WAF) is an optional component that handles incoming requests before they reach a listener. WAF checks each request for common threats based on OWASP rules.

## Terraform Implementation

### Application Gateway with WAF

```hcl
resource "azurerm_application_gateway" "waf" {
  name                = "ag-waf"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"  # or "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"         # or "2.2.9"
    
    # Optional: Disable specific rules
    disabled_rule_group {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      rules           = [942100, 942110]
    }
    
    # File upload limits
    file_upload_limit_mb = 100
    
    # Request body inspection
    request_body_check          = true
    max_request_body_size_kb    = 128
  }

  # ... other configuration ...
}
```

### WAF Modes

**Detection Mode:**
- Logs threats but doesn't block requests
- Useful for testing and evaluation
- Monitor without impacting traffic

```hcl
waf_configuration {
  enabled       = true
  firewall_mode = "Detection"
  # ... other configuration ...
}
```

**Prevention Mode:**
- Blocks requests matching threat patterns
- Recommended for production
- Protects against attacks

```hcl
waf_configuration {
  enabled       = true
  firewall_mode = "Prevention"
  # ... other configuration ...
}
```

### OWASP Rule Sets

**CRS 3.0 (Recommended):**
- Default and more recent rule set
- Better protection against modern attacks
- Continuously updated

```hcl
waf_configuration {
  rule_set_type    = "OWASP"
  rule_set_version = "3.2"
}
```

**CRS 2.2.9:**
- Older rule set
- Legacy compatibility
- Less comprehensive protection

```hcl
waf_configuration {
  rule_set_type    = "OWASP"
  rule_set_version = "2.2.9"
}
```

### Custom WAF Rules

```hcl
waf_configuration {
  # ... other configuration ...
  
  # Disable specific rule groups
  disabled_rule_group {
    rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
    rules           = [942100, 942110]
  }
  
  # Custom rules
  custom_rule {
    name      = "BlockSpecificIP"
    priority  = 1
    rule_type = "MatchRule"
    action    = "Block"
    
    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "User-Agent"
      }
      operator           = "Contains"
      negation_condition = false
      match_values       = ["BadBot"]
    }
  }
}
```

## WAF Protection Against

- SQL Injection
- Cross-Site Scripting (XSS)
- Command Injection
- HTTP Request Smuggling
- HTTP Response Splitting
- Remote File Inclusion
- Bots, Crawlers, and Scanners
- HTTP Protocol Violations and Anomalies

## Additional Resources

- [Web Application Firewall Overview](https://learn.microsoft.com/en-us/azure/application-gateway/web-application-firewall-overview)
- [OWASP Core Rule Sets](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-crs-rulegroups-rules)

