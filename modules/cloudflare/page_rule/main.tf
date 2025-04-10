terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Create page rules
resource "cloudflare_page_rule" "this" {
  for_each = { for idx, rule in var.page_rules : idx => rule }

  zone_id  = var.zone_id
  target   = each.value.target
  priority = each.value.priority

  actions {
    # Handle all possible page rule actions
    always_use_https = lookup(each.value.actions, "always_use_https", null)
    cache_level      = lookup(each.value.actions, "cache_level", null)
    browser_cache_ttl = lookup(each.value.actions, "browser_cache_ttl", null)
    edge_cache_ttl   = lookup(each.value.actions, "edge_cache_ttl", null)
    
    dynamic "forwarding_url" {
      for_each = lookup(each.value.actions, "forwarding_url", null) != null ? [lookup(each.value.actions, "forwarding_url", null)] : []
      content {
        url         = forwarding_url.value.url
        status_code = forwarding_url.value.status_code
      }
    }
    
    dynamic "minify" {
      for_each = lookup(each.value.actions, "minify", null) != null ? [lookup(each.value.actions, "minify", null)] : []
      content {
        html = lookup(minify.value, "html", "off")
        css  = lookup(minify.value, "css", "off")
        js   = lookup(minify.value, "js", "off")
      }
    }
  }
}
