# Floating IP has been removed
# - 138.197.233.163 (floating_ip_sfo2)

# Domains
module "domain_nbdonate_org" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "nbdonate.org"
  
  # Domain records
  a_records = {
    "@" = {
      value = "165.227.48.24"
      ttl   = 3600
    }
  }
  
  # No firewall
  create_firewall = false
}

module "domain_pausatf_internal" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "pausatf.internal"
  
  # No firewall
  create_firewall = false
}

module "domain_pausatf_steelhouselabs_com" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "pausatf.steelhouselabs.com"
  
  # No firewall
  create_firewall = false
}

module "domain_pausatf_tacklebox_io" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "pausatf.tacklebox.io"
  
  # No firewall
  create_firewall = false
}

module "domain_pupznpalz_dev" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "pupznpalz.dev"
  
  # No firewall
  create_firewall = false
}

module "domain_tacklebox_io" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "tacklebox.io"
  
  # No firewall
  create_firewall = false
}

module "domain_tantalum_io" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "tantalum.io"
  
  # No firewall
  create_firewall = false
}

# NS records are automatically created by DigitalOcean when a domain is added
