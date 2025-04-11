# Terraform and Provider Versions
# This file defines version constraints for Terraform and providers

terraform {
  # Terraform version constraint
  required_version = ">= 1.0.0"
  
  # Provider version constraints
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "~> 0.7.0"
    }
    sendgrid = {
      source  = "Meuko/sendgrid"
      version = "~> 1.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    # The template provider doesn't support darwin_arm64 (Apple Silicon)
    # Using the templatefile function instead is recommended
    # template = {
    #   source  = "hashicorp/template"
    #   version = "~> 2.0"
    # }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
