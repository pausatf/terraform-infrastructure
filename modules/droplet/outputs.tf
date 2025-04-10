output "id" {
  description = "The ID of the droplet"
  value       = digitalocean_droplet.this.id
}

output "name" {
  description = "The name of the droplet"
  value       = digitalocean_droplet.this.name
}

output "ipv4_address" {
  description = "The public IPv4 address of the droplet"
  value       = digitalocean_droplet.this.ipv4_address
}

output "ipv4_address_private" {
  description = "The private IPv4 address of the droplet"
  value       = digitalocean_droplet.this.ipv4_address_private
}

output "urn" {
  description = "The uniform resource name of the droplet"
  value       = digitalocean_droplet.this.urn
}

output "tags" {
  description = "The tags of the droplet"
  value       = digitalocean_droplet.this.tags
}
