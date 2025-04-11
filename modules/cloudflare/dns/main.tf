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

# Create DNS records
resource "cloudflare_record" "this" {
  for_each = { for idx, record in var.records : "${record.name}-${record.type}-${idx}" => record }

  zone_id = var.zone_id
  name    = each.value.name == "@" ? "" : each.value.name  # Empty string for root domain
  type    = each.value.type
  content = each.value.value  # Using content instead of value (value is deprecated)
  ttl     = each.value.ttl
  proxied = each.value.proxied
  allow_overwrite = true  # Allow overwriting existing records
}
