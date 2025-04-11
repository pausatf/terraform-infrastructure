# SendGrid Module Outputs
# This file defines all outputs from the SendGrid module

output "api_key" {
  description = "SendGrid API key (if created)"
  value       = local.create_resources && var.create_api_key ? sendgrid_api_key.this[0].api_key : null
  sensitive   = true
}

output "domain_authentication" {
  description = "SendGrid domain authentication records"
  value       = null
  sensitive   = true
}

output "templates" {
  description = "SendGrid templates"
  value       = local.create_resources ? {
    for key, template in sendgrid_template.this : key => {
      id   = template.id
      name = template.name
    }
  } : null
}

output "subuser_credentials" {
  description = "SendGrid subuser credentials"
  value       = local.create_resources && var.create_subuser ? {
    username = sendgrid_subuser.app_integration[0].username
    password = var.subuser_password != "" ? var.subuser_password : random_password.subuser[0].result
  } : null
  sensitive   = true
}
