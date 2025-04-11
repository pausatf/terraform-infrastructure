# WordPress Multi-Environment Configuration
# This file defines the WordPress infrastructure with dev, stage, and prod environments

locals {
  # WordPress configuration
  wordpress = {
    name          = "pausatf-wordpress-multi-env"
    size          = "s-2vcpu-4gb"
    image         = "litespeedtechnol-openlitespeedwor-20-04"
    volume_size   = 60
    database_size = "db-s-1vcpu-2gb"
    database_name = "wordpress-multi-env-db"
  }
  
  # DNS configuration
  dns = {
    ttl = 3600
  }
  
  # Security configuration
  security = {
    ssh_port = 22
    http_ports = [
      {
        protocol   = "tcp"
        port_range = "80"
      },
      {
        protocol   = "tcp"
        port_range = "443"
      },
      {
        protocol   = "tcp"
        port_range = "7080"  # OpenLiteSpeed WebAdmin Console
      }
    ]
  }
}

# WordPress Droplet
module "wordpress_droplet" {
  source = "./modules/droplet"
  
  name     = local.wordpress.name
  size     = local.wordpress.size
  image    = local.wordpress.image
  region   = var.region
  vpc_uuid = module.vpc_sfo2.vpc_id
  
  backups            = true
  monitoring         = true
  ssh_keys           = [data.digitalocean_ssh_key.m3_laptop.id]
  
  tags = concat(local.common_tags, ["env:multi", "role:wordpress"])
  
  # User data script to configure WordPress with multiple environments
  user_data = templatefile("${path.module}/wordpress-multi-env-user-data.sh", {
    db_host     = module.wordpress_database.host
    db_user     = module.wordpress_database.user
 db_password = module.wordpress_database.password
 admin_email = var.wp_admin_email
 admin_user = var.wp_admin_user
 domain_name = var.domain_name
 data_directory = "/mnt/wordpress-data"
 environments = local.environments
 })
  
  # Prevent accidental destruction
  prevent_destroy = true
}

# MySQL Database for WordPress
module "wordpress_database" {
  source = "./modules/database"
  
  name           = local.wordpress.database_name
  engine         = "mysql"
  engine_version = "8"
  size           = local.wordpress.database_size
  region         = var.region
  node_count     = 1
  
  private_network_uuid = module.vpc_sfo2.vpc_id
  
  tags = concat(local.common_tags, ["env:multi", "role:wordpress-db"])
  
  # Create WordPress databases for each environment
  databases = [for env in keys(local.environments) : local.environments[env].db_name]
  
  # Create WordPress user
  users = ["wordpress"]
  
  # Initially allow all traffic from the VPC
  firewall_rules = [
    {
      type  = "ip_addr"
      value = local.vpcs.sfo2.ip_range
    }
  ]
  
  # Prevent accidental destruction
  prevent_destroy = true
  
  # Configure maintenance window for low-traffic period
  maintenance_window = {
    day  = "sunday"
    hour = "02:00"
  }
}

# Database firewall rule to allow access from the WordPress droplet
resource "digitalocean_database_firewall" "wordpress_db_firewall" {
  cluster_id = module.wordpress_database.id
  
  rule {
    type  = "droplet"
    value = module.wordpress_droplet.id
  }
  
  # Ensure both resources are created first
  depends_on = [
    module.wordpress_database,
    module.wordpress_droplet
  ]
}

# WordPress firewall
module "wordpress_firewall" {
  source = "./modules/networking"
  
  # VPC settings (not used for firewall)
  vpc_name = local.vpcs.sfo2.name
  
  # Firewall settings
  create_domain   = false
  create_firewall = true
  firewall_name   = "${local.wordpress.name}-firewall"
  droplet_ids     = [module.wordpress_droplet.id]
  
  # HTTP and HTTPS ports
  inbound_rules = concat(
    local.security.http_ports,
    [
      {
        protocol         = "tcp"
        port_range       = tostring(local.security.ssh_port)
        source_addresses = ["0.0.0.0/0"]  # Consider restricting to specific IPs
      }
    ]
  )
  
  # Allow all outbound traffic
  outbound_rules = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  ]
}

# Volume for WordPress data
resource "digitalocean_volume" "wordpress_data" {
  region                  = var.region
  name                    = "${local.wordpress.name}-data"
  size                    = local.wordpress.volume_size
  description             = "WordPress data volume for multi-environment setup"
  initial_filesystem_type = "ext4"
  
  tags = concat(local.common_tags, ["env:multi", "role:wordpress-data"])
  
  lifecycle {
    prevent_destroy = true
  }
}

# Attach volume to WordPress droplet
resource "digitalocean_volume_attachment" "wordpress_data_attachment" {
  droplet_id = module.wordpress_droplet.id
  volume_id  = digitalocean_volume.wordpress_data.id
}

# DNS Records for all environments
resource "digitalocean_domain" "wordpress_domain" {
  name = var.domain_name
}

# Create DNS records for each environment
resource "digitalocean_record" "wordpress_environments" {
  for_each = local.environments
  
  domain = digitalocean_domain.wordpress_domain.name
  type   = "A"
  name   = each.value.subdomain
  value  = module.wordpress_droplet.ipv4_address
  ttl    = local.dns.ttl
}

# Root domain record
resource "digitalocean_record" "wordpress_root" {
  domain = digitalocean_domain.wordpress_domain.name
  type   = "A"
  name   = "@"
  value  = module.wordpress_droplet.ipv4_address
  ttl    = local.dns.ttl
}

# SMTP configuration for WordPress
resource "null_resource" "configure_smtp" {
  count = var.smtp_host != "" ? 1 : 0
  
  # Only run when SMTP configuration changes
  triggers = {
    smtp_host     = var.smtp_host
    smtp_port     = var.smtp_port
    smtp_user     = var.smtp_user
    smtp_password = var.smtp_password
    smtp_from     = var.smtp_from_email
  }
  
  # Configure SMTP for each environment
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      host        = module.wordpress_droplet.ipv4_address
      private_key = var.ssh_private_key
    }
    
    inline = [
      "cd /var/www/prod && wp plugin install wp-mail-smtp --activate --allow-root",
      "cd /var/www/prod && wp option set wp_mail_smtp '{\"mail\":{\"from_email\":\"${var.smtp_from_email}\",\"from_name\":\"${var.smtp_from_name}\",\"mailer\":\"smtp\",\"return_path\":true,\"from_email_force\":true,\"from_name_force\":true},\"smtp\":{\"host\":\"${var.smtp_host}\",\"port\":${var.smtp_port},\"encryption\":\"tls\",\"auth\":true,\"autotls\":true,\"user\":\"${var.smtp_user}\",\"pass\":\"${var.smtp_password}\"}}' --format=json --allow-root",
      "cd /var/www/stage && wp plugin install wp-mail-smtp --activate --allow-root",
      "cd /var/www/stage && wp option set wp_mail_smtp '{\"mail\":{\"from_email\":\"${var.smtp_from_email}\",\"from_name\":\"${var.smtp_from_name}\",\"mailer\":\"smtp\",\"return_path\":true,\"from_email_force\":true,\"from_name_force\":true},\"smtp\":{\"host\":\"${var.smtp_host}\",\"port\":${var.smtp_port},\"encryption\":\"tls\",\"auth\":true,\"autotls\":true,\"user\":\"${var.smtp_user}\",\"pass\":\"${var.smtp_password}\"}}' --format=json --allow-root",
      "cd /var/www/dev && wp plugin install wp-mail-smtp --activate --allow-root",
      "cd /var/www/dev && wp option set wp_mail_smtp '{\"mail\":{\"from_email\":\"${var.smtp_from_email}\",\"from_name\":\"${var.smtp_from_name}\",\"mailer\":\"smtp\",\"return_path\":true,\"from_email_force\":true,\"from_name_force\":true},\"smtp\":{\"host\":\"${var.smtp_host}\",\"port\":${var.smtp_port},\"encryption\":\"tls\",\"auth\":true,\"autotls\":true,\"user\":\"${var.smtp_user}\",\"pass\":\"${var.smtp_password}\"}}' --format=json --allow-root"
    ]
  }
  
  depends_on = [
    module.wordpress_droplet,
    digitalocean_volume_attachment.wordpress_data_attachment
  ]
}

# Outputs moved to outputs.tf
