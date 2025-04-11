# Cloudflare Module Variables

variable "enabled" {
  description = "Whether to enable Cloudflare integration"
  type        = bool
  default     = false
}

variable "api_token" {
  description = "Cloudflare API token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "domain" {
  description = "Domain for Cloudflare zone"
  type        = string
}

variable "server_ip" {
  description = "IP address of the server"
  type        = string
}

variable "environments" {
  description = "Environments to create DNS records for"
  type = map(object({
    subdomain = string
  }))
  default = {}
}

variable "dns_ttl" {
  description = "TTL for DNS records (1 for auto)"
  type        = number
  default     = 1
}

variable "proxy_dns" {
  description = "Whether to proxy DNS records through Cloudflare"
  type        = bool
  default     = true
}

variable "old_server_ip" {
  description = "IP address of the old server (to be renamed to old.domain.com)"
  type        = string
  default     = ""
}

variable "ssl_mode" {
  description = "SSL mode (off, flexible, full, strict)"
  type        = string
  default     = "full"
  
  validation {
    condition     = contains(["off", "flexible", "full", "strict"], var.ssl_mode)
    error_message = "SSL mode must be one of: off, flexible, full, strict."
  }
}

variable "security_level" {
  description = "Security level (essentially_off, low, medium, high, under_attack)"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["essentially_off", "low", "medium", "high", "under_attack"], var.security_level)
    error_message = "Security level must be one of: essentially_off, low, medium, high, under_attack."
  }
}

variable "cache_level" {
  description = "Cache level (aggressive, basic, simplified, standard)"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["aggressive", "basic", "simplified", "standard"], var.cache_level)
    error_message = "Cache level must be one of: aggressive, basic, simplified, standard."
  }
}

variable "rocket_loader" {
  description = "Rocket Loader setting (on, off)"
  type        = string
  default     = "off"
  
  validation {
    condition     = contains(["on", "off"], var.rocket_loader)
    error_message = "Rocket Loader must be one of: on, off."
  }
}

variable "custom_page_rules" {
  description = "Custom page rules to create"
  type = map(object({
    target   = string
    actions  = map(string)
    priority = number
  }))
  default = {}
}

variable "enable_waf" {
  description = "Whether to enable Web Application Firewall"
  type        = bool
  default     = true
}

variable "worker_script" {
  description = "Cloudflare Worker script content"
  type        = string
  default     = ""
}

variable "worker_route_pattern" {
  description = "Cloudflare Worker route pattern"
  type        = string
  default     = "*example.com/*"
}
