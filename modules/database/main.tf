terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Database Cluster
resource "digitalocean_database_cluster" "this" {
  name       = var.name
  engine     = var.engine
  version    = var.version
  size       = var.size
  region     = var.region
  node_count = var.node_count
  
  private_network_uuid = var.private_network_uuid
  
  tags = var.tags
  
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    
    content {
      day  = maintenance_window.value.day
      hour = maintenance_window.value.hour
    }
  }
  
  # Note: We can't use variables in lifecycle blocks
  # If you need to prevent destruction, uncomment the following:
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Database
resource "digitalocean_database_db" "this" {
  for_each = var.databases
  
  cluster_id = digitalocean_database_cluster.this.id
  name       = each.key
}

# Database User
resource "digitalocean_database_user" "this" {
  for_each = var.users
  
  cluster_id = digitalocean_database_cluster.this.id
  name       = each.key
}

# Database Connection Pool
resource "digitalocean_database_connection_pool" "this" {
  for_each = var.connection_pools
  
  cluster_id = digitalocean_database_cluster.this.id
  name       = each.key
  mode       = each.value.mode
  size       = each.value.size
  db_name    = each.value.db_name
  user       = each.value.user
}

# Database Firewall
resource "digitalocean_database_firewall" "this" {
  count = length(var.firewall_rules) > 0 ? 1 : 0
  
  cluster_id = digitalocean_database_cluster.this.id
  
  dynamic "rule" {
    for_each = var.firewall_rules
    
    content {
      type  = rule.value.type
      value = rule.value.value
    }
  }
}
