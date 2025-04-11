# Core infrastructure variables
variable "region" {
  description = "DigitalOcean region where resources will be created"
  type        = string
  default     = "sfo2"

  validation {
    condition     = contains(["nyc1", "nyc3", "sfo1", "sfo2", "sfo3", "ams3", "sgp1", "lon1", "fra1", "tor1", "blr1"], var.region)
    error_message = "Region must be a valid DigitalOcean region."
  }
}

variable "ssh_key_name" {
  description = "Name of the SSH key in DigitalOcean to use for droplet access"
  type        = string
  default     = "m3 laptop"
}

variable "project_name" {
  description = "Name of the DigitalOcean project where resources will be organized"
  type        = string
  default     = "PAUSATF"
}

variable "create_project" {
  description = "Whether to create a new project or use an existing one"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Primary domain name for the WordPress site"
  type        = string
  default     = "pausatf.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain name format."
  }
}

# WordPress configuration variables
variable "wp_admin_email" {
  description = "Email address for the WordPress admin user"
  type        = string
  default     = "admin@pausatf.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.wp_admin_email))
    error_message = "Admin email must be a valid email address format."
  }
}

variable "wp_admin_user" {
  description = "Username for the WordPress admin user"
  type        = string
  default     = "admin"

  validation {
    condition     = length(var.wp_admin_user) >= 4
    error_message = "Admin username must be at least 4 characters long."
  }
}

# API tokens and credentials (sensitive)
variable "digitalocean_token" {
  description = "DigitalOcean API token with write access"
  type        = string
  sensitive   = true
}

# Cloudflare configuration
variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone and DNS permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  default     = ""
  sensitive   = true
}

# Google Workspace configuration
variable "google_workspace_enabled" {
  description = "Whether to enable Google Workspace integration"
  type        = bool
  default     = false
}

# These variables are no longer used with OIDC authentication
# variable "google_workspace_credentials_json" {
#   description = "Google Workspace service account credentials JSON content"
#   type        = string
#   default     = ""
#   sensitive   = true
# }

# variable "google_workspace_service_account_email" {
#   description = "Google Workspace service account email"
#   type        = string
#   default     = ""
# }

# SendGrid configuration
variable "sendgrid_enabled" {
  description = "Whether to enable SendGrid integration"
  type        = bool
  default     = false
}

variable "sendgrid_api_key" {
  description = "SendGrid API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "sendgrid_sender_verification" {
  description = "Whether to verify the sender domain with SendGrid"
  type        = bool
  default     = true
}

variable "sendgrid_marketing_emails_enabled" {
  description = "Whether to enable marketing emails unsubscribe group"
  type        = bool
  default     = true
}

variable "sendgrid_notification_emails_enabled" {
  description = "Whether to enable notification emails unsubscribe group"
  type        = bool
  default     = true
}

# SMTP configuration
variable "smtp_host" {
  description = "SMTP server hostname"
  type        = string
  default     = "smtp.gmail.com"
}

variable "smtp_port" {
  description = "SMTP server port"
  type        = number
  default     = 587

  validation {
    condition     = var.smtp_port > 0 && var.smtp_port < 65536
    error_message = "SMTP port must be a valid port number (1-65535)."
  }
}

variable "smtp_user" {
  description = "SMTP username (Gmail address)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "smtp_password" {
  description = "SMTP password (Gmail app password)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "smtp_from_email" {
  description = "From email address for outgoing emails"
  type        = string
  default     = "noreply@pausatf.com"
}

variable "smtp_from_name" {
  description = "From name for outgoing emails"
  type        = string
  default     = "PAUSATF WordPress"
}

variable "ssh_private_key" {
  description = "SSH private key for remote execution"
  type        = string
  sensitive   = true
  default     = ""
}
