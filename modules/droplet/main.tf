terraform {
  # Terraform version constraint
  required_version = ">= 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_droplet" "this" {
  name     = var.name
  size     = var.size
  image    = var.image
  region   = var.region
  vpc_uuid = var.vpc_uuid

  backups            = var.backups
  monitoring         = var.monitoring
  ssh_keys           = var.ssh_keys
  user_data          = var.user_data != null ? var.user_data : null

  tags = var.tags
  lifecycle {
    # Using a hardcoded value instead of a variable
  # prevent_destroy = true
  }
}
