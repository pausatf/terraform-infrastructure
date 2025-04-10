terraform {
  cloud {
    organization = "pausatf"
    workspaces {
      name = "do-terraform"
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

# Data source for current user
data "digitalocean_account" "current" {}

# SSH Key
data "digitalocean_ssh_key" "m3_laptop" {
  name = var.ssh_key_name
}

# VPCs
module "vpc_sfo1" {
  source = "./modules/networking"
  
  vpc_name    = "default-sfo1"
  region      = "sfo1"
  ip_range    = "10.112.0.0/20"
  description = ""
  
  # No domain or firewall for this VPC
  create_domain   = false
  create_firewall = false
}

module "vpc_sfo2" {
  source = "./modules/networking"
  
  vpc_name    = "default-sfo2"
  region      = "sfo2"
  ip_range    = "10.138.0.0/16"
  description = ""
  
  # No domain or firewall for this VPC
  create_domain   = false
  create_firewall = false
}

module "vpc_sfo3" {
  source = "./modules/networking"
  
  vpc_name    = "default-sfo3"
  region      = "sfo3"
  ip_range    = "10.124.0.0/20"
  description = ""
  
  # No domain or firewall for this VPC
  create_domain   = false
  create_firewall = false
}

# Projects
module "project_pausatf" {
  source = "./modules/project"
  
  name        = "PAUSATF"
  description = "Pacific Association of USA Track and Field"
  purpose     = "Website or blog"
  environment = "Production"
  is_default  = true
}

module "project_paws_that_matter" {
  source = "./modules/project"
  
  name        = "Paws That Matter"
  description = "Paws that matter rescue"
  purpose     = "Website or blog"
}

module "project_rescue_system" {
  source = "./modules/project"
  
  name        = "Rescue System"
  description = ""
  purpose     = "Web Application"
}

module "project_relenz" {
  source = "./modules/project"
  
  name        = "Relenz"
  description = "Update your project information under Settings"
  purpose     = "Operational / Developer tooling"
}
