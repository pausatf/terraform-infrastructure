output "ruleset" {
  description = "The created ruleset containing firewall rules"
  value       = cloudflare_ruleset.zone_custom_firewall
}
