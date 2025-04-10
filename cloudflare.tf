# Cloudflare configuration

# Provider configuration
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

# Sync configuration between Digital Ocean and Cloudflare
# The following examples show how to reference Digital Ocean resources in Cloudflare configuration

# Example: Zone configuration for pausatf.org (using existing zone)
module "zone_pausatf_org" {
  source = "./modules/cloudflare/zone_existing"
  
  zone_name  = "pausatf.org"
  zone_settings = {
    always_use_https = true
    ssl              = "strict"
  }
}

# The following resources are commented out because they already exist in Cloudflare
# and we don't want to manage them with Terraform at this time.

# Root domain record (handled separately due to import issues)
# resource "cloudflare_record" "root_domain" {
#   zone_id = module.zone_pausatf_org.zone_id
#   name    = "pausatf.org"  # Use the full domain name to match the existing record
#   type    = "A"
#   content = module.droplet_pausatforg_primary.ipv4_address
#   ttl     = 1
#   proxied = true
#   allow_overwrite = true
# }

# Example: DNS configuration that references Digital Ocean droplets
# module "dns_pausatf_org" {
#   source = "./modules/cloudflare/dns"
#   
#   zone_id = module.zone_pausatf_org.zone_id
#   records = [
#     # WWW subdomain pointing to the primary droplet
#     {
#       name    = "www"
#       type    = "A"
#       value   = module.droplet_pausatforg_primary.ipv4_address  # Will be used as 'content' in the module
#       ttl     = 1
#       proxied = true
#     },
#     # Mail subdomain pointing to the primary droplet
#     {
#       name    = "mail"
#       type    = "A"
#       value   = module.droplet_pausatforg_primary.ipv4_address  # Will be used as 'content' in the module
#       ttl     = 1
#       proxied = true
#     },
#     # Monitor subdomain pointing to the primary droplet
#     {
#       name    = "monitor"
#       type    = "A"
#       value   = module.droplet_pausatforg_primary.ipv4_address  # Will be used as 'content' in the module
#       ttl     = 1
#       proxied = true
#     },
#     # FTP subdomain pointing to the primary droplet
#     {
#       name    = "ftp"
#       type    = "A"
#       value   = module.droplet_pausatforg_primary.ipv4_address  # Will be used as 'content' in the module
#       ttl     = 1
#       proxied = false
#     }
#   ]
# }

# Example: Cloudflare firewall rules that match Digital Ocean firewall
# Note: Requires API token with Firewall Services permission
# module "firewall_pausatf_org" {
#   source = "./modules/cloudflare/firewall"
#   
#   zone_id = module.zone_pausatf_org.zone_id
#   rules   = [
#     # Allow traffic to web ports (matches Digital Ocean web-firewall)
#     {
#       description = "Allow HTTP and HTTPS traffic"
#       expression  = "(http.request.uri.path ne \"/wp-login.php\")"
#       action      = "skip"  # "skip" is equivalent to "allow" in the new ruleset API
#       priority    = 1
#     },
#     # Block WordPress login attempts from non-US countries
#     {
#       description = "Block non-US WordPress login attempts"
#       expression  = "(http.request.uri.path eq \"/wp-login.php\") and (not ip.geoip.country in {\"US\"})"
#       action      = "block"
#       priority    = 2
#     }
#   ]
# }

# Example: Page rules for pausatf.org
# Note: Requires API token with Page Rules permission
# module "page_rule_pausatf_org" {
#   source = "./modules/cloudflare/page_rule"
#   
#   zone_id    = module.zone_pausatf_org.zone_id
#   page_rules = [
#     {
#       target   = "pausatf.org/wp-content/*"
#       priority = 1
#       actions  = {
#         cache_level = "cache_everything"
#         edge_cache_ttl = 86400 # 1 day
#       }
#     },
#     {
#       target   = "pausatf.org/wp-includes/*"
#       priority = 2
#       actions  = {
#         cache_level = "cache_everything"
#         edge_cache_ttl = 86400 # 1 day
#       }
#     }
#   ]
# }
