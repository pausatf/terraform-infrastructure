output "id" {
  description = "The ID of the project"
  value       = digitalocean_project.this.id
}

output "name" {
  description = "The name of the project"
  value       = digitalocean_project.this.name
}

output "description" {
  description = "The description of the project"
  value       = digitalocean_project.this.description
}

output "purpose" {
  description = "The purpose of the project"
  value       = digitalocean_project.this.purpose
}

output "environment" {
  description = "The environment of the project"
  value       = digitalocean_project.this.environment
}

output "is_default" {
  description = "Whether this is the default project"
  value       = digitalocean_project.this.is_default
}

output "owner_uuid" {
  description = "The UUID of the project owner"
  value       = digitalocean_project.this.owner_uuid
}

output "owner_id" {
  description = "The ID of the project owner"
  value       = digitalocean_project.this.owner_id
}

output "created_at" {
  description = "The creation date of the project"
  value       = digitalocean_project.this.created_at
}

output "updated_at" {
  description = "The last update date of the project"
  value       = digitalocean_project.this.updated_at
}
