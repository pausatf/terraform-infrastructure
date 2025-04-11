# SendGrid Module Variables
# This file defines all variables used in the SendGrid module

variable "enabled" {
  description = "Whether to enable SendGrid resources"
  type        = bool
  default     = true
}

variable "api_key" {
  description = "SendGrid API key for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "create_api_key" {
  description = "Whether to create a new SendGrid API key"
  type        = bool
  default     = false
}

variable "api_key_name" {
  description = "Name for the SendGrid API key"
  type        = string
  default     = "terraform-managed-key"
}

variable "api_key_scopes" {
  description = "Scopes for the SendGrid API key"
  type        = list(string)
  default     = ["mail.send", "templates.read", "templates.write"]
}

variable "domain" {
  description = "Domain for SendGrid sender authentication"
  type        = string
  default     = ""
}

variable "organization_name" {
  description = "Organization name for email templates"
  type        = string
  default     = "Organization"
}

variable "support_email" {
  description = "Support email address for email templates"
  type        = string
  default     = "support@example.com"
}

variable "custom_templates" {
  description = "Custom email templates to merge with default templates"
  type = map(object({
    name          = string
    subject       = string
    html_content  = string
    plain_content = string
  }))
  default = {}
}

variable "create_subuser" {
  description = "Whether to create a SendGrid subuser"
  type        = bool
  default     = false
}

variable "subuser_username" {
  description = "Username for the SendGrid subuser"
  type        = string
  default     = "app-integration"
}

variable "subuser_email" {
  description = "Email address for the SendGrid subuser"
  type        = string
  default     = ""
}

variable "subuser_password" {
  description = "Password for the SendGrid subuser (if empty, a random password will be generated)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "subuser_ips" {
  description = "IPs for the SendGrid subuser"
  type        = list(string)
  default     = []
}

variable "password_length" {
  description = "Length of the generated password for the SendGrid subuser"
  type        = number
  default     = 16
}
