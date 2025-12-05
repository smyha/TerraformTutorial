# Azure CDN Module

This module creates an Azure CDN profile and endpoints for content delivery.

## Features

- Global content distribution
- Multiple CDN providers (Microsoft, Verizon, Akamai)
- Dynamic acceleration
- Compression
- HTTPS support
- Custom domains
- Geo-filtering

## Usage

```hcl
module "cdn" {
  source = "./modules/cdn"
  
  resource_group_name = "rg-example"
  location            = "global"
  
  cdn_profile_name = "cdn-profile-main"
  sku              = "Standard_Microsoft"
  
  cdn_endpoints = {
    "web-endpoint" = {
      name                = "cdn-web"
      origin_host_header  = "www.example.com"
      origins = [
        {
          name       = "web-origin"
          host_name  = "www.example.com"
          http_port  = 80
          https_port = 443
        }
      ]
      is_http_allowed               = true
      is_https_allowed              = true
      querystring_caching_behaviour = "IgnoreQueryString"
      is_compression_enabled        = true
      content_types_to_compress     = ["text/html", "text/css", "application/javascript"]
    }
  }
}
```

## Outputs

- `cdn_profile_id`: The ID of the CDN profile
- `cdn_endpoint_ids`: Map of CDN endpoint names to IDs
- `cdn_endpoint_hostnames`: Map of CDN endpoint names to hostnames

