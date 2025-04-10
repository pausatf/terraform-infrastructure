terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Get existing zone
data "cloudflare_zone" "this" {
  name = var.zone_name
}
