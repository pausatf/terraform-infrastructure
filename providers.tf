# Provider Configurations

# DigitalOcean Provider (already configured in main.tf)
# provider "digitalocean" {
#   token = var.digitalocean_token
# }

# Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# SendGrid Provider
provider "sendgrid" {
  api_key = var.sendgrid_api_key
}

# Google Workspace Provider is configured in google_workspace.tf
