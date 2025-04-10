terraform {
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
  
  tags = var.tags

  # Note: We can't use variables in lifecycle blocks
  # If you need to prevent destruction, uncomment the following:
  # lifecycle {
  #   prevent_destroy = true
  # }
}
