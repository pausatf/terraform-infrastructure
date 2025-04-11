# PAUSATF OpenLiteSpeed WordPress Terraform Deployment

This Terraform configuration deploys an OpenLiteSpeed WordPress instance for
PAUSATF on Digital Ocean using the marketplace image and a managed MySQL
database. It also includes resources for migrating the existing PAUSATF
WordPress site.

## Prerequisites

1. Digital Ocean API token with write access
2. SSH key uploaded to Digital Ocean (referenced in `variables.tf`)
3. Terraform installed locally or using Terraform Cloud

## Configuration

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your
   Digital Ocean API token:

```bash
digitalocean_token = "your_api_token_here"
```

1. Review and update the PAUSATF OpenLiteSpeed WordPress configuration in
   `wordpress.tf` if needed:
   - Droplet size (default: s-1vcpu-2gb)
   - Database size (default: db-s-1vcpu-1gb)
   - Volume size (default: 10GB)
   - Region (default: sfo2)
   - Backup settings
   - Firewall rules

## Deployment

1. Initialize Terraform:

```bash
terraform init
```

1. Plan the deployment:

```bash
terraform plan
```

1. Apply the configuration:

```bash
terraform apply
```

1. After deployment, Terraform will output:
   - PAUSATF WordPress droplet IP address
   - Database connection details
   - WordPress admin URL
   - WordPress volume path (for migration)

## Accessing PAUSATF OpenLiteSpeed WordPress

1. Access your PAUSATF OpenLiteSpeed WordPress site by navigating to the
   droplet's IP address in your browser:

```bash
http://<pausatf_wordpress_droplet_ip>
```

1. Access the WordPress admin panel:

```bash
http://<pausatf_wordpress_droplet_ip>/wp-admin/
```

1. Complete the WordPress setup using the database connection details from the
   Terraform output:
   - Database Name: wordpress
   - Username: wordpress
   - Password: (from terraform output)
   - Database Host: (from terraform output)
   - Table Prefix: wp_

## Migrating the Existing PAUSATF WordPress Site

This configuration includes a 60GB volume attached to the droplet at
`/mnt/wordpress-data` for migrating the existing PAUSATF WordPress site. To migrate:

1. Use the provided migration script:

```bash
./wordpress-migration.sh --source-host old-pausatf.org --source-user admin \
  --source-path /var/www/html --db-host db.pausatf.org --db-name pausatf_wp \
  --db-user pausatf_user --target-ip <pausatf_wordpress_droplet_ip>
```

1. The script will:
   - Export the database from the old server
   - Copy WordPress files to the new server
   - Import the database to the new managed MySQL database
   - Update the WordPress configuration
   - Configure the web server to serve the migrated site

## Database Connection

The PAUSATF OpenLiteSpeed WordPress droplet is configured to connect to the MySQL
database using the private network. The database firewall is configured to allow
connections from the WordPress droplet.

## Maintenance

- The PAUSATF OpenLiteSpeed WordPress droplet has backups enabled
- The database is a managed MySQL instance with automatic updates and maintenance

## Cleanup

To destroy the resources created by this configuration:

```bash
terraform destroy
```

**Note:** This will permanently delete all data in the PAUSATF OpenLiteSpeed
WordPress instance and database.

## OpenLiteSpeed WebAdmin Console

The OpenLiteSpeed WebAdmin Console is accessible at:

```bash
https://<pausatf_wordpress_droplet_ip>:7080
```

Default credentials:

- Username: admin
- Password: Check the server for the default password or reset it using the command:

```bash
sudo /usr/local/lsws/admin/misc/admpass.sh
```
