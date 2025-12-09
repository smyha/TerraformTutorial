# Implementing Application Gateway Advanced Features with Terraform

## Overview

Application Gateway provides advanced features including redirection, header rewriting, custom error pages, and SSL/TLS configuration.

## Terraform Implementation

### HTTP to HTTPS Redirection

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  # Redirect configuration
  redirect_configuration {
    name                 = "httpToHttps"
    redirect_type        = "Permanent"
    target_listener_name = "httpsListener"
    include_path         = true
    include_query_string = true
  }

  # HTTP listener with redirect
  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                        = "redirectRule"
    rule_type                   = "Basic"
    http_listener_name          = "httpListener"
    redirect_configuration_name = "httpToHttps"
  }
}
```

### Header Rewriting

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  # Rewrite rule set
  rewrite_rule_set {
    name = "rewriteRuleSet"

    rewrite_rule {
      name          = "addHeader"
      rule_sequence = 100

      request_header_configuration {
        header_name  = "X-Forwarded-For"
        header_value = "{var_client_ip}"
      }

      response_header_configuration {
        header_name  = "X-Custom-Header"
        header_value = "CustomValue"
      }
    }
  }

  # Associate rewrite rule set with routing rule
  request_routing_rule {
    name                  = "ruleWithRewrite"
    rule_type             = "Basic"
    http_listener_name    = "httpListener"
    backend_address_pool_name = "backendPool"
    backend_http_settings_name = "httpSettings"
    rewrite_rule_set_name = "rewriteRuleSet"
  }
}
```

### Custom Error Pages

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  # Custom error page configuration
  custom_error_configuration {
    status_code           = "HttpStatus403"
    custom_error_page_url = "https://example.com/403.html"
  }

  custom_error_configuration {
    status_code           = "HttpStatus502"
    custom_error_page_url = "https://example.com/502.html"
  }
}
```

## Additional Resources

- [Application Gateway Redirection](https://learn.microsoft.com/en-us/azure/application-gateway/redirect-overview)
- [Header Rewriting](https://learn.microsoft.com/en-us/azure/application-gateway/rewrite-http-headers-url)
- [Custom Error Pages](https://learn.microsoft.com/en-us/azure/application-gateway/custom-error)

