resource "digitalocean_project" "pausatf_project" {
  name        = "PAUSATF Project"
  description = "PAUSATF Main Project"
  purpose     = "PAUSATF Website and Services"
  environment = "Production"
  resources   = [
    module.wordpress_droplet.urn,
    module.wordpress_database.urn,
    digitalocean_volume.wordpress_data.urn,
  ]
}

# Output the project details
output "pausatf_project_id" {
  value = digitalocean_project.pausatf_project.id
}

output "pausatf_project_name" {
  value = digitalocean_project.pausatf_project.name
}
