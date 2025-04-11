# PAUSATF OpenLiteSpeed WordPress Multi-Environment Terraform Deployment

This Terraform configuration deploys an OpenLiteSpeed WordPress instance for
PAUSATF on Digital Ocean with three separate environments (Development, Staging,
and Production) using virtual hosts. Each environment has its own database and
WordPress installation but runs on the same droplet for cost efficiency.

## Environments

The deployment includes three separate WordPress environments:

1. **Development (DEV)**: 
   - URL: http://dev.pausatf.com
   - Database: wordpress_dev
   - Table Prefix: wp_dev_
   - Debug Mode: Enabled

2. **Staging (STAGE)**:
   - URL: http://stage.pausatf.com
   - Database: wordpress_stage
   - Table Prefix: wp_stage_
   - Debug Mode: Disabled

3. **Production (PROD)**:
   - URL: http://www.pausatf.com and http://pausatf.com
   - Database: wordpress_prod
   - Table Prefix: wp_prod_
   - Debug Mode: Disabled

## Prerequisites

1. Digital Ocean API token with write access
2. SSH key uploaded to Digital Ocean (referenced in `variables.tf`)
3. Terraform installed locally or using Terraform Cloud
4. Domain (pausatf.com) configured in Digital Ocean DNS

## Configuration

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your
   Digital Ocean API token:

```bash
digitalocean_token = "your_api_token_here"
```

2. Review and update the PAUSATF OpenLiteSpeed WordPress configuration in
   `wordpress.tf` if needed:
   - Droplet size (default: s-2vcpu-4gb)
   - Database size (default: db-s-1vcpu-2gb)
   - Volume size (default: 60GB)
   - Region (default: sfo2)
   - Backup settings
   - Firewall rules

## Deployment

1. Initialize Terraform:

```bash
terraform init
```

2. Plan the deployment:

```bash
terraform plan
```

3. Apply the configuration:

```bash
terraform apply
```

4. After deployment, Terraform will output:
   - PAUSATF WordPress Multi-Environment droplet IP address
   - Database connection details
   - URLs for each environment
   - WordPress admin URLs for each environment
   - OpenLiteSpeed WebAdmin Console URL

## Accessing PAUSATF OpenLiteSpeed WordPress Environments

### Development Environment

Access the development environment at:
```
http://dev.pausatf.com
```

Admin panel:
```
http://dev.pausatf.com/wp-admin/
```

### Staging Environment

Access the staging environment at:
```
http://stage.pausatf.com
```

Admin panel:
```
http://stage.pausatf.com/wp-admin/
```

### Production Environment

Access the production environment at:
```
http://www.pausatf.com
```
or
```
http://pausatf.com
```

Admin panel:
```
http://www.pausatf.com/wp-admin/
```

## OpenLiteSpeed WebAdmin Console

The OpenLiteSpeed WebAdmin Console is accessible at:

```
https://<droplet_ip>:7080
```

Default credentials:

- Username: admin
- Password: Check the server for the default password or reset it using the command:

```bash
sudo /usr/local/lsws/admin/misc/admpass.sh
```

## Development Workflow

The multi-environment setup enables a proper development workflow:

1. Develop and test new features in the **Development** environment
2. Once features are ready, deploy them to the **Staging** environment for testing
3. After thorough testing, deploy to the **Production** environment

### Migrating Changes Between Environments

To migrate changes from Development to Staging:

1. Export the Development database:
```bash
ssh root@<droplet_ip> "mysqldump -h <db_host> -u <db_user> -p<db_password> wordpress_dev > /tmp/dev_export.sql"
```

2. Import to Staging (after making any necessary modifications):
```bash
ssh root@<droplet_ip> "mysql -h <db_host> -u <db_user> -p<db_password> wordpress_stage < /tmp/dev_export.sql"
```

3. Update table prefixes if needed:
```bash
ssh root@<droplet_ip> "mysql -h <db_host> -u <db_user> -p<db_password> wordpress_stage -e \"UPDATE wp_stage_options SET option_name = REPLACE(option_name, 'wp_dev_', 'wp_stage_') WHERE option_name LIKE 'wp_dev_%';\""
```

4. Copy files if needed:
```bash
ssh root@<droplet_ip> "cp -r /var/www/dev/wp-content/themes/your-theme /var/www/stage/wp-content/themes/"
```

Follow a similar process to migrate from Staging to Production.

## Database Isolation

Each environment has its own database:

- Development: wordpress_dev
- Staging: wordpress_stage
- Production: wordpress_prod

This ensures that changes in one environment don't affect the others.

## File Structure

Each environment has its own directory on the server:

- Development: /var/www/dev
- Staging: /var/www/stage
- Production: /var/www/prod

## Maintenance

- The PAUSATF OpenLiteSpeed WordPress droplet has backups enabled
- The database is a managed MySQL instance with automatic updates and maintenance

## Cleanup

To destroy the resources created by this configuration:

```bash
terraform destroy
```

**Note:** This will permanently delete all data in all three environments.

## Troubleshooting

### DNS Issues

If you can't access the environments by domain name, check:

1. DNS propagation (may take up to 48 hours)
2. DNS records in Digital Ocean

### Database Connection Issues

If WordPress can't connect to the database:

1. Check the database firewall rules
2. Verify the database credentials in wp-config.php
3. Ensure the database exists and is accessible

### OpenLiteSpeed Configuration

If you need to modify the OpenLiteSpeed configuration:

1. Access the WebAdmin Console
2. Or modify configuration files directly:
   - Main config: /usr/local/lsws/conf/httpd_config.conf
   - Virtual hosts: /usr/local/lsws/conf/vhosts/[env]/vhconf.conf
