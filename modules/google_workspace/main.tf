# Google Workspace Module
# This module manages Google Workspace resources

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "~> 0.7.0"
    }
  }
}

provider "googleworkspace" {
  customer_id = var.customer_id
  impersonated_user_email = var.admin_email
  
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
  create_google_workspace = var.enabled

  email_groups = {
    admin = {
      email       = "admin@${var.domain}"
      name        = "Administrators"
      description = "${var.organization_name} Administrators"
      members     = ["admin@${var.domain}"]
    }
    info = {
      email       = "info@${var.domain}"
      name        = "Information"
      description = "${var.organization_name} Information"
      members     = ["admin@${var.domain}"]
    }
    support = {
      email       = "support@${var.domain}"
      name        = "Support"
      description = "${var.organization_name} Support"
      members     = ["admin@${var.domain}"]
    }
    noreply = {
      email       = "noreply@${var.domain}"
      name        = "No Reply"
      description = "${var.organization_name} No Reply"
      members     = []
    }
  }

  merged_groups  = merge(local.email_groups, var.custom_groups)
  default_email_aliases = {
    admin   = ["administrator@${var.domain}", "webmaster@${var.domain}"]
    info    = ["contact@${var.domain}", "hello@${var.domain}"]
    support = ["help@${var.domain}"]
  }
  merged_aliases = merge(local.default_email_aliases, var.custom_aliases)
}

resource "googleworkspace_domain" "primary_domain" {
  count       = local.create_google_workspace ? 1 : 0
  domain_name = var.domain
}

resource "googleworkspace_group" "groups" {
  for_each = local.create_google_workspace ? local.merged_groups : {}
  email       = each.value.email
  name        = each.value.name
  description = each.value.description

  depends_on = [googleworkspace_domain.primary_domain]
}

resource "googleworkspace_group_member" "group_members" {
  for_each = local.create_google_workspace ? {
    for pair in flatten([
      for group_key, group in local.merged_groups : [
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
