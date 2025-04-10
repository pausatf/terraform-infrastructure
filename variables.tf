variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "sfo2"  # Most of your resources are in sfo2
}

variable "ssh_key_name" {
  description = "SSH key name"
  type        = string
  default     = "m3 laptop"  # Your existing SSH key
}

variable "project_name" {
  description = "Default project name"
  type        = string
  default     = "PAUSATF"  # Your default project
}

variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

# Cloudflare variables
variable "cloudflare_api_token" {
  description = "Cloudflare API token with appropriate permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_name" {
  description = "Cloudflare account name"
  type        = string
  default     = "Your Cloudflare Account"  # Replace with your actual account name
}
