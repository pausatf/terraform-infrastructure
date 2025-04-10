# Database Cluster Outputs
output "id" {
  description = "The ID of the database cluster"
  value       = digitalocean_database_cluster.this.id
}

output "name" {
  description = "The name of the database cluster"
  value       = digitalocean_database_cluster.this.name
}

output "engine" {
  description = "Database engine"
  value       = digitalocean_database_cluster.this.engine
}

output "version" {
  description = "Engine version"
  value       = digitalocean_database_cluster.this.version
}

output "host" {
  description = "Database hostname"
  value       = digitalocean_database_cluster.this.host
}

output "private_host" {
  description = "Database private hostname"
  value       = digitalocean_database_cluster.this.private_host
}

output "port" {
  description = "Database port"
  value       = digitalocean_database_cluster.this.port
}

output "uri" {
  description = "Database connection URI"
  value       = digitalocean_database_cluster.this.uri
  sensitive   = true
}

output "private_uri" {
  description = "Database private connection URI"
  value       = digitalocean_database_cluster.this.private_uri
  sensitive   = true
}

output "database" {
  description = "Default database name"
  value       = digitalocean_database_cluster.this.database
}

output "user" {
  description = "Default user name"
  value       = digitalocean_database_cluster.this.user
}

output "password" {
  description = "Default user password"
  value       = digitalocean_database_cluster.this.password
  sensitive   = true
}

output "urn" {
  description = "The uniform resource name of the database cluster"
  value       = digitalocean_database_cluster.this.urn
}

# Database Outputs
output "databases" {
  description = "Map of database names to their IDs"
  value       = { for db in digitalocean_database_db.this : db.name => db.id }
}

# User Outputs
output "users" {
  description = "Map of user names to their IDs"
  value       = { for user in digitalocean_database_user.this : user.name => user.id }
}

# Connection Pool Outputs
output "connection_pools" {
  description = "Map of connection pool names to their IDs"
  value       = { for pool in digitalocean_database_connection_pool.this : pool.name => pool.id }
}
