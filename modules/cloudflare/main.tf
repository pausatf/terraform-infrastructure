# Cloudflare Module
# This module manages Cloudflare resources

terraform {
  # Terraform version constraint
  required_version = ">= 1.0.0"
  
  # Provider version constraints
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Note: Provider configuration is now expected to be passed by the caller

# Local variables for Cloudflare configuration
locals {
  # Only create Cloudflare resources if API token is provided
  create_cloudflare = var.enabled
  
  # Default page rules
  default_page_rules = {
    wp_admin = {
      target = "*${var.domain}/wp-admin/*"
      actions = {
        cache_level = "bypass"
      }
      priority = 1
    },
    wp_login = {
      target = "*${var.domain}/wp-login.php*"
      actions = {
        cache_level = "bypass"
      }
      priority = 2
    },
    static_content = {
      target = "*${var.domain}/wp-content/*"
      actions = {
        cache_level = "cache_everything"
      }
      priority = 3
    }
  }
  
  # Merge default page rules with custom page rules
  merged_page_rules = merge(local.default_page_rules, var.custom_page_rules)
}

# Get Cloudflare zone details
data "cloudflare_zone" "domain" {
  count = local.create_cloudflare ? 1 : 0
  
  name = var.domain
}

# DNS Records for all environments
resource "cloudflare_record" "environments" {
  for_each = local.create_cloudflare ? var.environments : {}
  
  zone_id  = data.cloudflare_zone.domain[0].id
  name     = each.value.subdomain
  content  = var.server_ip
  type     = "A"
  ttl      = var.dns_ttl
  proxied  = var.proxy_dns
}

# Root domain record
resource "cloudflare_record" "root" {
  count = local.create_cloudflare ? 1 : 0
  
  zone_id  = data.cloudflare_zone.domain[0].id
  name     = "@"
  content  = var.server_ip
  type     = "A"
  ttl      = var.dns_ttl
  proxied  = var.proxy_dns
}

# Old server record (if applicable)
resource "cloudflare_record" "old_server" {
  count = local.create_cloudflare && var.old_server_ip != "" ? 1 : 0
  
  zone_id  = data.cloudflare_zone.domain[0].id
  name     = "old"
  content  = var.old_server_ip
  type     = "A"
  ttl      = var.dns_ttl
  proxied  = var.proxy_dns
}

# SSL Settings
resource "cloudflare_zone_settings_override" "settings" {
  count = local.create_cloudflare ? 1 : 0
  
  zone_id = data.cloudflare_zone.domain[0].id
  
  settings {
    # SSL Settings
    ssl = var.ssl_mode
    always_use_https = "on"
    automatic_https_rewrites = "on"
    opportunistic_encryption = "on"
    tls_1_3 = "on"
    min_tls_version = "1.2"
    
    # Security Settings
    security_level = var.security_level
    browser_check = "on"
    challenge_ttl = 2700
    privacy_pass = "on"
    
    # Performance Settings
    brotli = "on"
    minify {
      css = "on"
      html = "on"
      js = "on"
    }
    rocket_loader = var.rocket_loader
    cache_level = var.cache_level
    
    # Other Settings
    always_online = "on"
    development_mode = "off"
    sort_query_string_for_cache = "on"
    email_obfuscation = "on"
    server_side_exclude = "on"
    hotlink_protection = "on"
  }
}

# Page Rules
resource "cloudflare_page_rule" "page_rules" {
  for_each = local.create_cloudflare ? local.merged_page_rules : {}
  
  zone_id  = data.cloudflare_zone.domain[0].id
  target   = each.value.target
  priority = each.value.priority
  
  actions {
    cache_level = each.value.actions.cache_level
  }
}

# Web Application Firewall (WAF) Settings
# Note: cloudflare_waf_package is no longer supported
# Consider using cloudflare_ruleset or other modern WAF resources instead
# For now, we'll comment this out to prevent errors
/*
resource "cloudflare_ruleset" "wordpress_waf" {
  count = local.create_cloudflare && var.enable_waf ? 1 : 0
  
  zone_id = data.cloudflare_zone.domain[0].id
  name    = "WordPress WAF"
  kind    = "zone"
  phase   = "http_request_firewall_managed"
  
  # Configure specific rules as needed
}
*/

# Cloudflare Workers (if enabled)
resource "cloudflare_workers_script" "worker" {
  count = local.create_cloudflare && var.worker_script != "" ? 1 : 0
  
  name       = "${var.domain}-worker"
  content    = var.worker_script
  account_id = var.account_id
}

resource "cloudflare_workers_route" "worker_route" {
  count = local.create_cloudflare && var.worker_script != "" ? 1 : 0
  
  zone_id     = data.cloudflare_zone.domain[0].id
  pattern     = var.worker_route_pattern
  script_name = cloudflare_workers_script.worker[0].name
}
