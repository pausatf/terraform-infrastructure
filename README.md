# Digital Ocean and Cloudflare Terraform Configuration

This repository contains Terraform configuration for managing Digital Ocean  
infrastructure and Cloudflare resources using a modular approach with best practices.

## Structure

The configuration is organized into modules for better reusability and maintainability:

```hcl
do-terraform/
├── modules/
│   ├── database/       # Database cluster management
│   ├── droplet/        # Droplet (VM) management
│   ├── networking/     # VPC, Domain, and Firewall management
│   ├── project/        # Project management
│   └── cloudflare/     # Cloudflare resource management
│       ├── dns/        # DNS record management
│       ├── zone/       # Zone management
│       ├── firewall/   # Firewall rule management
│       ├── page_rule/  # Page rule management
│       └── worker/     # Worker script and route management
├── main.tf             # Provider configuration and VPC/Project modules
├── droplets.tf         # Droplet and Firewall resources
├── networking.tf       # Domain resources
├── databases.tf        # Database resources (commented out)
├── projects.tf         # Project resource associations
├── cloudflare.tf       # Cloudflare resource configuration
├── variables.tf        # Variable definitions
└── terraform.tfvars    # Variable values
```

## Modules

### Droplet Module

Manages Digital Ocean Droplets (VMs) with consistent configuration:

- Consistent naming convention
- Tagging for organization and filtering
- Lifecycle management to prevent accidental destruction
- SSH key management

### Networking Module

Manages VPCs, Domains, and Firewalls:

- VPC configuration with proper IP ranges
- Domain management with DNS records
- Firewall rules for securing resources

### Database Module

Manages Database Clusters with:

- Engine configuration
- Private networking
- User and database management
- Connection pools
- Firewall rules

### Project Module

Manages Projects and resource organization:

- Project metadata
- Resource associations

### Cloudflare Modules

The Cloudflare modules provide a structured way to manage Cloudflare resources:

#### DNS Module

Manages DNS records for Cloudflare zones:

- A, AAAA, CNAME, TXT, MX, and other record types
- Proxied and non-proxied records
- TTL configuration
- **Integration with Digital Ocean**: DNS records can reference Digital Ocean droplet IPs directly

#### Zone Module

Creates and configures Cloudflare zones:

- Zone creation and settings
- SSL configuration
- Security settings

#### Firewall Module

Creates firewall rules for Cloudflare zones using the modern ruleset API:

- Rule expressions using Cloudflare's filter syntax
- Actions (block, challenge, js_challenge, allow)
- Priority management
- **Integration with Digital Ocean**: Firewall rules can complement Digital Ocean firewall settings
- Uses the new `cloudflare_ruleset` resource (replacing deprecated filter/firewall_rule resources)

#### Page Rule Module

Creates page rules for Cloudflare zones:

- URL pattern matching
- Cache settings
- Security settings
- Forwarding rules

#### Worker Module

Creates worker scripts and routes:

- JavaScript worker code management
- Route pattern configuration
- Environment variables and bindings

### Syncing Digital Ocean and Cloudflare

To ensure that your Digital Ocean infrastructure and Cloudflare configuration remain in sync:

1. **Reference Digital Ocean Resources**: In your Cloudflare configuration, reference
   Digital Ocean resources directly:

   ```hcl
   # DNS record pointing to a Digital Ocean droplet
   {
     name    = "www"
     type    = "A"
     value   = module.droplet_web.ipv4_address  # Will be used as 'content' in the module
     ttl     = 3600
     proxied = true
   }
   ```

2. **Complementary Firewall Rules**: Ensure that your Cloudflare firewall rules
   complement your Digital Ocean firewall settings:
   - Digital Ocean firewalls control traffic to your servers
   - Cloudflare firewalls control traffic to your websites before it reaches your servers

3. **Use the Sync Script**: Run the provided sync_state.sh script to verify that your
   configurations are in sync:

   ```bash
   ./sync_state.sh
   ```

   This script will:
   - Check if DNS records reference the correct droplet IPs
   - Verify that firewall rules are consistent between Digital Ocean and Cloudflare
   - Identify any drift between your Terraform state and the actual infrastructure

## Best Practices Implemented

### Organization and Structure

- **Modular Design**: Resources are organized into reusable modules
- **Consistent Naming**: Resources follow a consistent naming convention
- **Tagging Strategy**: Resources are tagged for better organization and filtering

### Resource Management

- **Project Resources**: Resources are properly associated with projects
- **Resource Lifecycle Management**: Critical resources have `prevent_destroy`  
  set to prevent accidental deletion
- **Firewall Rules**: Network access is restricted with firewall rules

## Usage

### Prerequisites

- Terraform v1.0.0+
- Digital Ocean API token with write access

### Getting Started

1. Clone this repository
2. Set your Digital Ocean API token in `terraform.tfvars` or as an environment variable:

   ```bash
   export TF_VAR_digitalocean_token="your_token"
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Plan your changes:

   ```bash
   terraform plan
   ```

5. Apply changes:

   ```bash
   terraform apply
   ```

## Adding New Resources

### Adding a New Droplet

```hcl
module "droplet_new" {
  source = "./modules/droplet"
  
  name     = "new-droplet"
  size     = "s-1vcpu-1gb"
  image    = "ubuntu-20-04-x64"
  region   = "sfo2"
  vpc_uuid = module.vpc_sfo2.vpc_id
  
  tags = ["production", "web", "app-name"]
  
  prevent_destroy = true
}
```

### Adding a New Database

```hcl
module "new_db" {
  source = "./modules/database"
  
  name       = "new-db"
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = "sfo2"
  node_count = 1
  
  private_network_uuid = module.vpc_sfo2.vpc_id
  
  tags = ["mysql", "production", "app-name"]
  
  prevent_destroy = true
}
```

### Adding a New Domain

```hcl
module "domain_new" {
  source = "./modules/networking"
  
  # VPC settings (not used for domain)
  vpc_name    = "unused"
  region      = "sfo2"
  ip_range    = "10.0.0.0/24"
  
  # Domain settings
  create_domain = true
  domain_name   = "example.com"
  
  # Domain records
  a_records = {
    "@" = {
      value = "192.0.2.1"
      ttl   = 3600
    }
  }
  
  # No firewall
  create_firewall = false
}
```

### Adding Cloudflare Resources

#### Adding a Cloudflare Zone

```hcl
module "zone_example_com" {
  source = "./modules/cloudflare/zone"
  
  account_id = local.cloudflare_account_id
  zone_name  = "example.com"
  settings   = {
    plan = "free"
    type = "full"
  }
  zone_settings = {
    always_use_https = true
    ssl              = "strict"
  }
}
```

#### Adding DNS Records

```hcl
module "dns_example_com" {
  source = "./modules/cloudflare/dns"
  
  zone_id = module.zone_example_com.zone_id
  records = [
    {
      name    = "@"
      type    = "A"
      value   = module.droplet_web.ipv4_address  # Used as 'content' in the module
      ttl     = 3600
      proxied = true
    },
    {
      name    = "www"
      type    = "CNAME"
      value   = "example.com"  # Will be used as 'content' in the module
      proxied = true
    }
  ]
}
```

#### Adding Firewall Rules

```hcl
module "firewall_example_com" {
  source = "./modules/cloudflare/firewall"
  
  zone_id = module.zone_example_com.zone_id
  rules   = [
    {
      description = "Block country X"
      expression  = "(ip.geoip.country eq \"X\")"
      action      = "block"
      priority    = 1
    }
  ]
}
```

## Maintenance

### Syncing with Digital Ocean

To ensure your Terraform state is in sync with Digital Ocean:

```bash
terraform refresh
terraform plan
```

### Transitioning to Modular Structure

To transition from the old structure to the new modular structure without  
destroying and recreating resources, use the provided migration script:

```bash
./migrate_to_modules.sh
```

This script will:

1. Remove the resources from the current Terraform state
2. Import them into the new module structure
3. Preserve the actual resources in Digital Ocean

This approach ensures that your infrastructure is not destroyed and recreated
during the transition to the modular structure.

After running the migration script, run `terraform plan` to see if there are any
remaining differences. You may still see some attribute changes, but the
resources themselves should not be destroyed and recreated.

### Importing New Resources

For importing new resources that aren't yet managed by Terraform, use the  
`import_resources.sh` script.

### Syncing with Cloudflare

To ensure your Terraform state is in sync with Cloudflare:

```bash
./sync_state.sh
```

### Importing Existing Cloudflare Resources

If you already have resources in Cloudflare that you want to manage with Terraform,
you can import them into your Terraform state:

```bash
./import_cloudflare_resources.sh
```

This script will:

1. Identify existing Cloudflare resources (zones, DNS records, page rules, etc.)
2. Import them into your Terraform state
3. Ensure that Terraform doesn't try to create resources that already exist

### Generating Terraform from Existing Cloudflare Infrastructure

To generate Terraform configuration from your existing Cloudflare infrastructure:

```bash
export CLOUDFLARE_API_TOKEN="your_token"
./generate_terraform.sh
```

This script will:

1. Query your Cloudflare account for all resources (zones, DNS records, etc.)
2. Generate Terraform configuration files in the `terraform_output` directory
3. Create worker script files for any Cloudflare Workers you have

You can then review the generated files and use them as a starting point for
your Terraform configuration.
