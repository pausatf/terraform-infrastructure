# SendGrid Configuration
# This file manages SendGrid integration for the PAUSATF WordPress deployment

# SendGrid integration
module "sendgrid" {
  source = "./modules/sendgrid"

  # Enable SendGrid resources if API key is provided
  enabled = var.sendgrid_enabled
  api_key = var.sendgrid_api_key

  # Organization details
  organization_name = var.project_name
  support_email     = "support@${var.domain_name}"
  domain            = var.sendgrid_sender_verification ? var.domain_name : ""

  # API key configuration
  create_api_key = true
  api_key_name   = "terraform-managed-key"
  api_key_scopes = ["mail.send", "templates.read", "templates.write"]

  # Subuser configuration
  create_subuser   = true
  subuser_username = "wordpress"
  subuser_email    = "wordpress@${var.domain_name}"
  subuser_ips      = []
  password_length  = 16
}


# Create unsubscribe group for marketing emails
resource "sendgrid_unsubscribe_group" "marketing" {
  count = var.sendgrid_enabled && var.sendgrid_marketing_emails_enabled ? 1 : 0

  name        = "${var.project_name} Marketing"
  description = "Marketing emails from ${var.project_name}"
  is_default  = true
}

# Create unsubscribe group for notification emails
resource "sendgrid_unsubscribe_group" "notifications" {
  count = var.sendgrid_enabled && var.sendgrid_notification_emails_enabled ? 1 : 0

  name        = "${var.project_name} Notifications"
  description = "Notification emails from ${var.project_name}"
  is_default  = false
}

# Output SendGrid configuration for use in other modules
output "sendgrid" {
  description = "SendGrid configuration"
  value = {
    api_key               = module.sendgrid.api_key
    domain_authentication = module.sendgrid.domain_authentication
    templates             = module.sendgrid.templates
    subuser_credentials   = module.sendgrid.subuser_credentials
    unsubscribe_groups    = {
      marketing     = var.sendgrid_enabled && var.sendgrid_marketing_emails_enabled && length(sendgrid_unsubscribe_group.marketing) > 0 ? sendgrid_unsubscribe_group.marketing[0].id : null
      notifications = var.sendgrid_enabled && var.sendgrid_notification_emails_enabled && length(sendgrid_unsubscribe_group.notifications) > 0 ? sendgrid_unsubscribe_group.notifications[0].id : null
    }
     }
  sensitive = true
}
