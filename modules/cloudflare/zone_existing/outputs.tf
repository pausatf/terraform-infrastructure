output "zone_id" {
  description = "The ID of the Cloudflare zone"
  value       = data.cloudflare_zone.this.id
}

output "zone_name" {
  description = "The name of the Cloudflare zone"
  value       = data.cloudflare_zone.this.name
}
