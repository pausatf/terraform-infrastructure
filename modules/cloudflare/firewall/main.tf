terraform {
  # Terraform version constraint
  required_version = ">= 1.0.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Create firewall rules using the new ruleset API
resource "cloudflare_ruleset" "zone_custom_firewall" {
  zone_id     = var.zone_id
  name        = "Zone Custom Firewall Rules"
  description = "Custom firewall rules for the zone"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  dynamic "rules" {
    for_each = { for idx, rule in var.rules : idx => rule }
    content {
      action      = rules.value.action
      expression  = rules.value.expression
      description = rules.value.description
      enabled     = true
      
      # Convert priority to ref (lower number = higher priority)
      ref = format("rule-%d", rules.value.priority)
    }
  }
}
