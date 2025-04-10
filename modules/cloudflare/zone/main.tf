terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Create zone
resource "cloudflare_zone" "this" {
  account_id = var.account_id
  zone       = var.zone_name
  plan       = var.settings.plan
  type       = var.settings.type
}

# Configure zone settings
# Note: Requires API token with Zone Settings permission
resource "cloudflare_zone_settings_override" "this" {
  zone_id = cloudflare_zone.this.id
  
  settings {
    # Security settings
    always_use_https         = lookup(var.zone_settings, "always_use_https", true)
    automatic_https_rewrites = lookup(var.zone_settings, "automatic_https_rewrites", "on")
    ssl                      = lookup(var.zone_settings, "ssl", "strict")
    
    # Performance settings
    browser_cache_ttl        = lookup(var.zone_settings, "browser_cache_ttl", 14400)
    min_tls_version          = lookup(var.zone_settings, "min_tls_version", "1.2")
    
    # Other settings
    challenge_ttl            = lookup(var.zone_settings, "challenge_ttl", 1800)
    security_level           = lookup(var.zone_settings, "security_level", "medium")
  }
}
