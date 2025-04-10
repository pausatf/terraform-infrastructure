# Active Droplets
module "droplet_pausatf_org" {
  source = "./modules/droplet"
  
  name     = "pausatf.org"
  size     = "s-4vcpu-8gb"
  image    = "77072287"  # Using the existing image ID
  region   = "sfo2"
  vpc_uuid = module.vpc_sfo2.vpc_id
  
  backups            = true
  monitoring         = false
  ssh_keys           = []
  
  tags = ["production", "web", "pausatf"]
  
  # Note: To prevent accidental destruction, uncomment the lifecycle block in the module
}

module "droplet_pausatforg_primary" {
  source = "./modules/droplet"
  
  name     = "pausatforg20230516-primary"
  size     = "s-4vcpu-8gb"
  image    = "132778991"  # Using the existing image ID
  region   = "sfo2"
  vpc_uuid = module.vpc_sfo2.vpc_id
  
  monitoring         = false
  ssh_keys           = []
  
  tags = ["test", "production", "web", "pausatf"]
  
  # Note: To prevent accidental destruction, uncomment the lifecycle block in the module
}

# Firewall for web servers
module "firewall_web" {
  source = "./modules/networking"
  
  # VPC settings (not used for firewall)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Firewall settings
  create_domain   = false
  create_firewall = true
  firewall_name   = "web-firewall"
  droplet_ids     = [
    module.droplet_pausatf_org.id,
    module.droplet_pausatforg_primary.id
  ]
  
  inbound_rules = [
    {
      protocol = "tcp"
      port_range = "80"
    },
    {
      protocol = "tcp"
      port_range = "443"
    },
    {
      protocol = "tcp"
      port_range = "22"
      # Restrict SSH access to specific IPs in production
      source_addresses = ["0.0.0.0/0"] # Replace with your office/home IP
    }
  ]
  
  outbound_rules = [
    {
      protocol = "tcp"
      port_range = "1-65535"
    },
    {
      protocol = "udp"
      port_range = "1-65535"
    },
    {
      protocol = "icmp"
    }
  ]
}

# Powered-off Droplets have been removed
# - openlitespeedwordpress643onubuntu2204-s-1vcpu-1gb-amd-sfo3-01 (wordpress_amd)
# - openlitespeedwordpress643onubuntu2204-s-1vcpu-2gb-sfo3-01 (wordpress_2gb)
