# SendGrid Module
# This module manages SendGrid resources using the Meuko/sendgrid provider

terraform {
  # Terraform version constraint
  required_version = ">= 1.0.0"

  # Provider version constraints
  required_providers {
    sendgrid = {
      source  = "Meuko/sendgrid"
      version = "~> 1.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Local variables for SendGrid configuration
locals {
  # Determine if SendGrid resources should be created
  create_resources = var.enabled && var.api_key != ""
  
  # Default email templates with consistent structure
  default_templates = {
    welcome = {
      name    = "${var.organization_name} Welcome Email"
      subject = "Welcome to ${var.organization_name}"
      html_content = templatefile("${path.module}/templates/welcome.html.tftpl", {
        organization_name = var.organization_name
        support_email     = var.support_email
      })
      plain_content = templatefile("${path.module}/templates/welcome.txt.tftpl", {
        organization_name = var.organization_name
        support_email     = var.support_email
      })
    }
    password_reset = {
      name    = "${var.organization_name} Password Reset"
      subject = "${var.organization_name} Password Reset"
      html_content = templatefile("${path.module}/templates/password_reset.html.tftpl", {
        organization_name = var.organization_name
      })
      plain_content = templatefile("${path.module}/templates/password_reset.txt.tftpl", {
        organization_name = var.organization_name
      })
    }
    notification = {
      name    = "${var.organization_name} Notification"
      subject = "${var.organization_name} Notification"
      html_content = templatefile("${path.module}/templates/notification.html.tftpl", {
        organization_name = var.organization_name
      })
      plain_content = templatefile("${path.module}/templates/notification.txt.tftpl", {
        organization_name = var.organization_name
      })
    }
  }
  
  # Merge default templates with custom templates, with custom templates taking precedence
  templates = merge(local.default_templates, var.custom_templates)
}

# API key resource
resource "sendgrid_api_key" "this" {
  count = local.create_resources && var.create_api_key ? 1 : 0
  
  name   = var.api_key_name
  scopes = var.api_key_scopes
}


# Email templates
resource "sendgrid_template" "this" {
  for_each = local.create_resources ? local.templates : {}
  
  name       = each.value.name
  generation = "dynamic"
}

# Template versions with content
resource "sendgrid_template_version" "this" {
  for_each = local.create_resources ? local.templates : {}
  
  template_id    = sendgrid_template.this[each.key].id
  name           = each.value.name
  subject        = each.value.subject
  html_content   = each.value.html_content
  plain_content  = each.value.plain_content
  active         = 1
}

# Subuser for application integration (e.g., WordPress)
resource "sendgrid_subuser" "app_integration" {
  count = local.create_resources && var.create_subuser ? 1 : 0
  
  username = var.subuser_username
  email    = var.subuser_email
  password = var.subuser_password != "" ? var.subuser_password : random_password.subuser[0].result
  ips      = var.subuser_ips
}

# Generate secure random password for subuser
resource "random_password" "subuser" {
  count = local.create_resources && var.create_subuser && var.subuser_password == "" ? 1 : 0
  
  length           = var.password_length
  special          = true
  min_special      = 2
  min_numeric      = 2
  min_upper        = 2
  min_lower        = 2
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?"
}
