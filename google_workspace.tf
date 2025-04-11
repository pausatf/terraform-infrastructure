# Google Workspace Configuration for PAUSATF

provider "googleworkspace" {
  customer_id = var.google_workspace_customer_id
  impersonated_user_email = var.google_workspace_admin_email
  
  # For OIDC, remove any explicit credentials setting
  # If you must use credentials, set them as a variable in Terraform Cloud

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.domain",
    "https://www.googleapis.com/auth/gmail.settings.sharing",
    "https://www.googleapis.com/auth/gmail.settings.basic"
  ]
}

locals {
  create_google_workspace = var.google_workspace_customer_id != "" && var.google_workspace_admin_email != ""

  email_groups = {
    admin = {
      email       = "admin@${var.google_workspace_domain}"
      name        = "Administrators"
      description = "PAUSATF Administrators"
      members     = ["admin@${var.google_workspace_domain}"]
    }
    info = {
      email       = "info@${var.google_workspace_domain}"
      name        = "Information"
      description = "PAUSATF Information"
      members     = ["admin@${var.google_workspace_domain}"]
    }
    support = {
      email       = "support@${var.google_workspace_domain}"
      name        = "Support"
      description = "PAUSATF Support"
      members     = ["admin@${var.google_workspace_domain}"]
    }
    noreply = {
      email       = "noreply@${var.google_workspace_domain}"
      name        = "No Reply"
      description = "PAUSATF No Reply"
      members     = []
    }
  }

  email_aliases = {
    admin   = ["administrator@${var.google_workspace_domain}", "webmaster@${var.google_workspace_domain}"]
    info    = ["contact@${var.google_workspace_domain}", "hello@${var.google_workspace_domain}"]
    support = ["help@${var.google_workspace_domain}"]
  }
}

resource "googleworkspace_domain" "primary_domain" {
  count       = local.create_google_workspace ? 1 : 0
  domain_name = var.google_workspace_domain
}

resource "googleworkspace_group" "groups" {
  for_each    = local.create_google_workspace ? local.email_groups : {}
  email       = each.value.email
  name        = each.value.name
  description = each.value.description

  depends_on = [googleworkspace_domain.primary_domain]
}

resource "googleworkspace_group_member" "group_members" {
  for_each = local.create_google_workspace ? {
    for pair in flatten([
      for group_key, group in local.email_groups : [
        for member in group.members : {
          key      = "${group_key}-${member}"
          group_id = googleworkspace_group.groups[group_key].id
          email    = member
        }
      ]
    ]) : pair.key => pair
  } : {}

  group_id = each.value.group_id
  email    = each.value.email
  role     = "MEMBER"

  depends_on = [googleworkspace_group.groups]
}

# This variable is no longer used with OIDC authentication
# variable "google_workspace_credentials_file" {
#   description = "Path to Google Workspace credentials file"
#   type        = string
#   default     = ""
#   sensitive   = true
# }

variable "google_workspace_admin_email" {
  description = "Admin email for impersonation"
  type        = string
  default     = ""
}

variable "google_workspace_customer_id" {
  description = "Google Workspace customer ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_workspace_domain" {
  description = "Primary domain for Google Workspace"
  type        = string
  default     = "pausatf.org"
}

output "google_workspace_domain" {
  description = "Google Workspace domain"
  value       = var.google_workspace_domain
}

output "google_workspace_groups" {
  description = "Google Workspace groups"
  value = local.create_google_workspace ? {
    for key, group in googleworkspace_group.groups : key => {
      email = group.email
      name  = group.name
    }
  } : null
}
