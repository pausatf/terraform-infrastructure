# Terraform Outputs
# This file contains all outputs for the PAUSATF WordPress infrastructure

# WordPress Infrastructure Outputs
output "wordpress_droplet_ip" {
  description = "The public IP address of the WordPress droplet"
  value       = module.wordpress_droplet.ipv4_address
}

output "wordpress_database" {
  description = "WordPress database connection details"
  value = {
    host     = module.wordpress_database.host
    port     = module.wordpress_database.port
    user     = module.wordpress_database.user
    password = module.wordpress_database.password
    uri      = module.wordpress_database.uri
    databases = {
      dev   = local.environments.dev.db_name
      stage = local.environments.stage.db_name
      prod  = local.environments.prod.db_name
    }
  }
  sensitive = true
}

# Environment URLs
output "wordpress_urls" {
  description = "WordPress environment URLs"
  value = {
    for env_key, env in local.environments : env_key => {
      site  = "https://${env.subdomain}.${var.domain_name}"
      admin = "https://${env.subdomain}.${var.domain_name}/wp-admin/"
    }
  }
}

# Root domain URL
output "wordpress_root_url" {
  description = "WordPress root domain URL"
  value       = "https://${var.domain_name}"
}

# Admin Console
output "wordpress_webadmin_console" {
  description = "OpenLiteSpeed WebAdmin Console URL"
  value       = "https://${module.wordpress_droplet.ipv4_address}:7080"
}

# Volume Information
output "wordpress_volume_path" {
  description = "The path where the WordPress data volume is mounted"
  value       = "/mnt/wordpress-data"
}

output "wordpress_volume_size" {
  description = "The size of the WordPress data volume in GB"
  value       = digitalocean_volume.wordpress_data.size
}

# Cloudflare Information
data "cloudflare_zone" "domain" {
  name = var.domain_name
}

output "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  value       = data.cloudflare_zone.domain.id
}

output "cloudflare_nameservers" {
  description = "Cloudflare nameservers for the domain"
  value       = data.cloudflare_zone.domain.name_servers
}

# Migration Information
output "migration_command" {
  description = "Command to run the migration script"
  value       = "bash wordpress-multi-env-migration.sh --source-host [OLD_HOST] --source-user [OLD_USER] --source-path [OLD_PATH] --target-ip ${module.wordpress_droplet.ipv4_address} --environment prod"
}

output "environment_sync_command" {
  description = "Command to sync between environments"
  value       = "bash wordpress-env-sync.sh --source dev --destination stage --target-ip ${module.wordpress_droplet.ipv4_address} --content all"
}

# SMTP Configuration Status
output "smtp_configured" {
  description = "Whether SMTP is configured"
  value       = var.smtp_host != "" ? "Yes (${var.smtp_host}:${var.smtp_port})" : "No"
}
