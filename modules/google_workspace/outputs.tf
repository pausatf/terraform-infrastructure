# Google Workspace Module Outputs

output "domain" {
  description = "Google Workspace domain"
  value       = var.domain
}

output "groups" {
  description = "Google Workspace groups"
  value       = local.create_google_workspace ? {
    for key, group in googleworkspace_group.groups : key => {
      id    = group.id
      email = group.email
      name  = group.name
    }
  } : null
}

output "group_members" {
  description = "Google Workspace group members"
  value       = local.create_google_workspace ? {
    for key, member in googleworkspace_group_member.group_members : key => {
      group_id = member.group_id
      email    = member.email
      role     = member.role
    }
  } : null
}

output "smtp_relay_configured" {
  description = "Whether SMTP relay is configured"
  value       = local.create_google_workspace && var.configure_smtp_relay
}

output "smtp_relay_settings" {
  description = "SMTP relay settings"
  value       = local.create_google_workspace && var.configure_smtp_relay ? {
    host         = var.smtp_relay_host
    port         = var.smtp_relay_port
    require_tls  = var.smtp_relay_require_tls
    require_auth = var.smtp_relay_require_auth
  } : null
}
