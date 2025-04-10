# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = data.digitalocean_vpc.existing.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = data.digitalocean_vpc.existing.name
}

output "vpc_urn" {
  description = "The uniform resource name of the VPC"
  value       = data.digitalocean_vpc.existing.urn
}

# Domain Outputs
output "domain_name" {
  description = "The name of the domain"
  value       = var.create_domain ? digitalocean_domain.this[0].name : null
}

output "domain_urn" {
  description = "The uniform resource name of the domain"
  value       = var.create_domain ? digitalocean_domain.this[0].urn : null
}

# Firewall Outputs
output "firewall_id" {
  description = "The ID of the firewall"
  value       = var.create_firewall ? digitalocean_firewall.this[0].id : null
}

output "firewall_name" {
  description = "The name of the firewall"
  value       = var.create_firewall ? digitalocean_firewall.this[0].name : null
}

output "firewall_status" {
  description = "The status of the firewall"
  value       = var.create_firewall ? digitalocean_firewall.this[0].status : null
}
