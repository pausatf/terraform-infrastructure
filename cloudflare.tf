# Cloudflare configuration
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Get account details
data "cloudflare_accounts" "current" {
  name = var.cloudflare_account_name
}

locals {
  cloudflare_account_id = data.cloudflare_accounts.current.accounts[0].id
}

# Zone configuration for pausatf.org (using existing zone)
module "zone_pausatf_org" {
  source = "./modules/cloudflare/zone_existing"
  
  zone_name  = "pausatf.org"
  zone_settings = {
    always_use_https = true
    ssl              = "strict"
  }
}
