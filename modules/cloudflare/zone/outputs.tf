output "zone_id" {
  description = "The zone ID"
  value       = cloudflare_zone.this.id
}

output "name_servers" {
  description = "The name servers for the zone"
  value       = cloudflare_zone.this.name_servers
}

output "status" {
  description = "The status of the zone"
  value       = cloudflare_zone.this.status
}

output "plan" {
  description = "The plan of the zone"
  value       = cloudflare_zone.this.plan
}
