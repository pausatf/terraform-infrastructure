output "worker_scripts" {
  description = "Map of created worker scripts"
  value       = cloudflare_worker_script.this
}

output "worker_routes" {
  description = "Map of created worker routes"
  value       = cloudflare_worker_route.this
}
