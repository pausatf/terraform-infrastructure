# Cloudflare Module Outputs

output "zone_id" {
  description = "Cloudflare Zone ID for the domain"
  value       = local.create_cloudflare ? data.cloudflare_zone.domain[0].id : null
}

output "nameservers" {
  description = "Cloudflare nameservers for the domain"
  value       = local.create_cloudflare ? data.cloudflare_zone.domain[0].name_servers : null
}

output "dns_records" {
  description = "DNS records created in Cloudflare"
  value       = local.create_cloudflare ? {
    environments = {
      for key, record in cloudflare_record.environments : key => {
        id      = record.id
        name    = record.name
        content = record.content
        proxied = record.proxied
      }
    }
    root = local.create_cloudflare ? {
      id      = cloudflare_record.root[0].id
      name    = cloudflare_record.root[0].name
      content = cloudflare_record.root[0].content
      proxied = cloudflare_record.root[0].proxied
    } : null
    old_server = local.create_cloudflare && var.old_server_ip != "" ? {
      id      = cloudflare_record.old_server[0].id
      name    = cloudflare_record.old_server[0].name
      content = cloudflare_record.old_server[0].content
      proxied = cloudflare_record.old_server[0].proxied
    } : null
  } : null
}

output "page_rules" {
  description = "Page rules created in Cloudflare"
  value       = local.create_cloudflare ? {
    for key, rule in cloudflare_page_rule.page_rules : key => {
      id       = rule.id
      target   = rule.target
      priority = rule.priority
    }
  } : null
}

output "waf_enabled" {
  description = "Whether WAF is enabled"
  value       = local.create_cloudflare && var.enable_waf
}

output "worker_enabled" {
  description = "Whether Cloudflare Worker is enabled"
  value       = local.create_cloudflare && var.worker_script != ""
}

output "worker_route" {
  description = "Cloudflare Worker route pattern"
  value       = local.create_cloudflare && var.worker_script != "" ? var.worker_route_pattern : null
}

output "ssl_mode" {
  description = "SSL mode configured in Cloudflare"
  value       = local.create_cloudflare ? var.ssl_mode : null
}

output "cache_level" {
  description = "Cache level configured in Cloudflare"
  value       = local.create_cloudflare ? var.cache_level : null
}
