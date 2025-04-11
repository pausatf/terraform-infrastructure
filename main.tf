# DigitalOcean WordPress Multi-Environment Infrastructure
# Terraform configuration for PAUSATF WordPress deployment

terraform {
  cloud {
    organization = "pausatf"
    workspaces {
      name = "pausatf"
    }
  }
}

# Provider configurations
provider "digitalocean" {
  token = var.digitalocean_token
}

# Common local values
locals {
  # Common tags for all resources
  common_tags = [
    "project:${var.project_name}",
    "managed-by:terraform"
  ]

  # Environment-specific configurations
  environments = {
    dev = {
      subdomain = "dev"
      db_name   = "wordpress_dev"
      db_prefix = "wp_dev_"
    }
    stage = {
      subdomain = "stage"
      db_name   = "wordpress_stage"
      db_prefix = "wp_stage_"
    }
    prod = {
      subdomain = "www"
      db_name   = "wordpress_prod"
      db_prefix = "wp_prod_"
    }
  }

  # VPC configurations
  vpcs = {
    sfo1 = {
      name     = "default-sfo1"
      region   = "sfo1"
      ip_range = "10.112.0.0/20"
    }
    sfo2 = {
      name     = "default-sfo2"
      region   = "sfo2"
      ip_range = "10.138.0.0/16"
    }
    sfo3 = {
      name     = "default-sfo3"
      region   = "sfo3"
      ip_range = "10.124.0.0/20"
    }
  }
}

data "digitalocean_ssh_key" "m3_laptop" {
  name = var.ssh_key_name
}

data "digitalocean_project" "pausatf" {
  name = var.project_name
}

# VPCs
module "vpc_sfo1" {
  source = "./modules/networking"

  vpc_name = local.vpcs.sfo1.name

  # No domain or firewall for this VPC
  create_domain   = false
  create_firewall = false
}

module "vpc_sfo2" {
  source = "./modules/networking"

  vpc_name = local.vpcs.sfo2.name

  # No domain or firewall for this VPC
  create_domain   = false
  create_firewall = false
}

module "vpc_sfo3" {
  source = "./modules/networking"

  vpc_name = local.vpcs.sfo3.name

  # No domain or firewall for this VPC
  create_domain   = false
  create_firewall = false
}

# Cloudflare integration
module "cloudflare" {
  source = "./modules/cloudflare"

  enabled    = true
  api_token  = var.cloudflare_api_token
  account_id = var.cloudflare_account_id
  domain     = var.domain_name
  server_ip  = module.wordpress_droplet.ipv4_address

  environments = {
    for env_key, env in local.environments : env_key => {
      subdomain = env.subdomain
    }
  }

  ssl_mode       = "full"
  security_level = "medium"
  cache_level    = "basic"
  rocket_loader  = "off"
  enable_waf     = true

  depends_on = [
    module.wordpress_droplet
  ]
}

# Google Workspace integration
module "google_workspace" {
  source = "./modules/google_workspace"

  enabled           = var.google_workspace_enabled
  # Using OIDC for authentication
  customer_id       = var.google_workspace_customer_id
  admin_email       = var.google_workspace_admin_email
  domain            = var.domain_name
  organization_name = var.project_name

  configure_smtp_relay    = true
  smtp_relay_host         = "smtp-relay.gmail.com"
  smtp_relay_port         = 587
  smtp_relay_require_tls  = true
  smtp_relay_require_auth = true
}

# SendGrid integration is now managed in sendgrid.tf
