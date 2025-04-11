# Google Workspace Module Variables

variable "enabled" {
  description = "Whether to enable Google Workspace integration"
  type        = bool
  default     = false
}

variable "credentials_json" {
  description = "Google Workspace service account credentials JSON content"
  type        = string
  default     = ""
  sensitive   = true
}

variable "customer_id" {
  description = "Google Workspace customer ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_email" {
  description = "Google Workspace admin email for impersonation"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Google Workspace service account email"
  type        = string
  default     = ""
}

variable "domain" {
  description = "Primary domain for Google Workspace"
  type        = string
}

variable "organization_name" {
  description = "Organization name for Google Workspace"
  type        = string
  default     = "Organization"
}

variable "custom_groups" {
  description = "Custom email groups to create"
  type = map(object({
    email       = string
    name        = string
    description = string
    members     = list(string)
  }))
  default = {}
}

variable "custom_aliases" {
  description = "Custom email aliases to create"
  type        = map(list(string))
  default     = {}
}

variable "configure_smtp_relay" {
  description = "Whether to configure SMTP relay"
  type        = bool
  default     = false
}

variable "smtp_relay_host" {
  description = "SMTP relay host"
  type        = string
  default     = "smtp-relay.gmail.com"
}

variable "smtp_relay_port" {
  description = "SMTP relay port"
  type        = number
  default     = 587
}

variable "smtp_relay_require_tls" {
  description = "Whether to require TLS for SMTP relay"
  type        = bool
  default     = true
}

variable "smtp_relay_require_auth" {
  description = "Whether to require authentication for SMTP relay"
  type        = bool
  default     = true
}

variable "smtp_relay_allowed_ips" {
  description = "IPs allowed to use SMTP relay"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
