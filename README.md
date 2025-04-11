# PAUSATF WordPress Multi-Environment Terraform Infrastructure

This repository contains Terraform configurations for deploying a multi-environment WordPress infrastructure on DigitalOcean with OpenLiteSpeed, managed MySQL database, Cloudflare integration, Google Workspace management, and SendGrid email services.

## Architecture

The infrastructure consists of:

- **Single DigitalOcean Droplet** running OpenLiteSpeed WordPress
- **Three WordPress Environments** (dev, stage, prod) using virtual hosts
- **Managed MySQL Database** with separate databases for each environment
- **Cloudflare Integration** for DNS, SSL, and security
- **Google Workspace Management** for email and user management
- **SendGrid Integration** for transactional emails
- **Postfix Configuration** for reliable email delivery via Gmail SMTP
- **Volume Storage** for WordPress data
- **SSH Key Setup** for secure server-to-server communication

## Directory Structure

```
.
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── versions.tf                  # Version constraints
├── wordpress.tf                 # WordPress infrastructure
├── cloudflare.tf                # Cloudflare configuration
├── google_workspace.tf          # Google Workspace configuration
├── sendgrid.tf                  # SendGrid configuration
├── projects.tf                  # Project organization
├── wordpress-multi-env-user-data.sh  # Droplet initialization script
├── wordpress-multi-env-migration.sh  # Migration script
├── wordpress-env-sync.sh        # Environment sync script
├── modules/                     # Reusable modules
│   ├── database/                # Database module
│   ├── droplet/                 # Droplet module
│   └── networking/              # Networking module
└── scripts/                     # Utility scripts
```

## Prerequisites

- Terraform v1.0.0 or newer
- DigitalOcean API token with write access
- Cloudflare API token with Zone and DNS permissions
- Google Workspace admin account (optional)
- SendGrid API key (optional)
- SSH key uploaded to DigitalOcean
- Domain name configured in Cloudflare

## Getting Started

1. Clone this repository:

```bash
git clone https://github.com/pausatf/do-terraform.git
cd do-terraform
```

2. Create a `terraform.tfvars` file with your credentials:

```hcl
# API Tokens
digitalocean_token   = "your_digitalocean_api_token"
cloudflare_api_token = "your_cloudflare_api_token"
cloudflare_zone_id   = "your_cloudflare_zone_id"

# Infrastructure Configuration
domain_name          = "pausatf.com"
ssh_key_name         = "your_ssh_key_name"

# Email Configuration
smtp_user            = "your_gmail_address@gmail.com"
smtp_password        = "your_gmail_app_password"

# Google Workspace (optional)
google_workspace_admin_email = "admin@pausatf.com"
google_workspace_customer_id = "your_customer_id"

# SendGrid (optional)
sendgrid_api_key     = "your_sendgrid_api_key"
```

3. Initialize Terraform:

```bash
terraform init
```

4. Plan the deployment:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

## Environment Management

### Accessing Environments

- **Development**: https://dev.pausatf.com
- **Staging**: https://stage.pausatf.com
- **Production**: https://www.pausatf.com

### Syncing Between Environments

Use the provided sync script to copy content between environments:

```bash
./wordpress-env-sync.sh --source dev --destination stage --target-ip <droplet_ip> --content all
```

## Migration

To migrate from an existing WordPress site:

```bash
./wordpress-multi-env-migration.sh --source-host old.pausatf.org --source-user admin \
  --source-path /var/www/html --target-ip <droplet_ip> --environment prod
```

The migration script uses SSH keys for secure server-to-server communication. The public key will be displayed during the droplet initialization, which you should add to the authorized_keys file on the old server.

## Email Configuration

### Gmail SMTP Integration

The infrastructure is configured to use Gmail SMTP for reliable email delivery. Postfix is automatically configured during the droplet initialization to use Gmail's SMTP server.

To set up Gmail SMTP:

1. Create an App Password in your Google Account
2. Add the Gmail address and App Password to your terraform.tfvars file:

```hcl
smtp_user     = "your_gmail_address@gmail.com"
smtp_password = "your_gmail_app_password"
```

### SendGrid Integration

For transactional emails, the infrastructure can be configured to use SendGrid:

```hcl
sendgrid_api_key      = "your_sendgrid_api_key"
sendgrid_from_email   = "noreply@pausatf.com"
sendgrid_from_name    = "PAUSATF WordPress"
```

This will set up SendGrid templates for welcome emails, password resets, and notifications.

## Google Workspace Management

The infrastructure can manage Google Workspace resources, including:

- Domain verification
- Email groups and aliases
- SMTP relay settings

To enable Google Workspace management:

1. Create a service account in Google Cloud Console
2. Grant the service account domain-wide delegation
3. Download the service account credentials JSON file
4. Add the following to your terraform.tfvars file:

```hcl
google_workspace_admin_email     = "admin@pausatf.com"
google_workspace_customer_id     = "your_customer_id"
google_workspace_credentials_file = "/path/to/credentials.json"
```

## Cloudflare Integration

The infrastructure uses Cloudflare for:

- DNS management with automatic record creation
- SSL/TLS encryption with Full (strict) mode
- Web Application Firewall (WAF) with WordPress-specific rules
- Page rules for WordPress optimization
- Performance optimization with Brotli compression and minification

## Maintenance

### Database Backups

The managed MySQL database has automatic backups enabled. You can also create manual backups:

```bash
ssh root@<droplet_ip> "cd /var/www/prod && wp db export backup.sql --allow-root"
```

### WordPress Updates

Update WordPress core, plugins, and themes:

```bash
ssh root@<droplet_ip> "cd /var/www/prod && wp core update --allow-root && wp plugin update --all --allow-root && wp theme update --all --allow-root"
```

## Security Considerations

- The infrastructure uses Cloudflare as a security layer
- SSH access is restricted to your SSH key
- Database access is restricted to the WordPress droplet
- WordPress admin areas have cache bypass rules
- SMTP authentication is secured with TLS
- SSH keys are used for server-to-server communication

## Troubleshooting

### Common Issues

- **Database Connection Errors**: Check the database firewall rules
- **SSL Certificate Issues**: Ensure Cloudflare SSL mode is set correctly
- **Email Delivery Problems**: Verify SMTP configuration or check SendGrid API key
- **Google Workspace Integration Issues**: Verify service account permissions

### Logs

Access logs on the droplet:

- OpenLiteSpeed logs: `/usr/local/lsws/logs/`
- WordPress debug log: `/var/www/[env]/wp-content/debug.log`
- Mail logs: `/var/log/mail.log`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
