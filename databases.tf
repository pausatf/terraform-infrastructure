# MySQL Databases - Commented out as these resources no longer exist in Digital Ocean
# Using the database module for future reference

/*
module "wordpress_db_sfo2" {
  source = "./modules/database"
  
  name       = "wordpress-db-73111"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = "sfo2"
  node_count = 1
  
  private_network_uuid = module.vpc_sfo2.vpc_id
  
  tags = ["wordpress-db", "production", "pausatf"]
  
  # Note: To prevent accidental destruction, uncomment the lifecycle block in the module
  
  # Create additional databases if needed
  databases = [
    "wordpress"
  ]
  
  # Create additional users if needed
  users = [
    "wordpress_user"
  ]
  
  # Configure firewall rules to restrict access
  firewall_rules = [
    {
      type  = "ip_addr"
      value = "0.0.0.0/0"  # Replace with specific IPs in production
    },
    {
      type  = "droplet"
      value = module.droplet_pausatf_org.id
    },
    {
      type  = "droplet"
      value = module.droplet_pausatforg_primary.id
    }
  ]
}

module "wordpress_db_sfo3" {
  source = "./modules/database"
  
  name       = "wordpress-db-93856"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = "sfo3"
  node_count = 1
  
  private_network_uuid = module.vpc_sfo3.vpc_id
  
  tags = ["wordpress-db", "staging", "pausatf"]
  
  # Note: To prevent accidental destruction, uncomment the lifecycle block in the module
  
  # Create additional databases if needed
  databases = [
    "wordpress"
  ]
  
  # Create additional users if needed
  users = [
    "wordpress_user"
  ]
  
  # Configure firewall rules to restrict access
  firewall_rules = [
    {
      type  = "ip_addr"
      value = "0.0.0.0/0"  # Replace with specific IPs in production
    }
  ]
}
*/

# Note: Default database and user are automatically created with the cluster
# and are already managed by DigitalOcean, so we don't need to create them.
# If you need additional databases or users, you can add them here.

# Example of how to create a new database cluster using the module:
/*
module "new_mysql_db" {
  source = "./modules/database"
  
  name       = "new-mysql-db"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = "sfo2"
  node_count = 1
  
  private_network_uuid = module.vpc_sfo2.vpc_id
  
  tags = ["mysql", "production", "app-name"]
  
  # Configure maintenance window
  maintenance_window = {
    day  = "sunday"
    hour = "02:00"
  }
  
  # Note: To prevent accidental destruction, uncomment the lifecycle block in the module
  
  # Create additional databases
  databases = [
    "app_db",
    "analytics_db"
  ]
  
  # Create additional users
  users = [
    "app_user",
    "analytics_user"
  ]
  
  # Create connection pools
  connection_pools = {
    app_pool = {
      mode    = "transaction"
      size    = 10
      db_name = "app_db"
      user    = "app_user"
    }
  }
  
  # Configure firewall rules
  firewall_rules = [
    {
      type  = "ip_addr"
      value = "203.0.113.0/24"  # Example IP range
    },
    {
      type  = "tag"
      value = "web-servers"
    }
  ]
}
*/
