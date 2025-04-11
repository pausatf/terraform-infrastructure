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

# Project
resource "digitalocean_project" "this" {
  name        = var.name
  description = var.description
  purpose     = var.purpose
  environment = var.environment
  is_default  = var.is_default
}

# Project Resources
resource "digitalocean_project_resources" "this" {
  count   = length(var.resources) > 0 ? 1 : 0
  project = digitalocean_project.this.id
  
  resources = var.resources
}
