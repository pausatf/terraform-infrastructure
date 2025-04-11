#!/bin/bash
# PAUSATF OpenLiteSpeed WordPress Multi-Environment User Data Script
# This script sets up three WordPress environments (dev, stage, prod) using OpenLiteSpeed virtual hosts

# Note: This script is a Terraform template. The following variables are provided by Terraform:
# - db_host: Database host
# - db_user: Database user
# - db_password: Database password
# - domain_name: Domain name
# - smtp_user: SMTP user (optional)
# - smtp_password: SMTP password (optional)
# - admin_email: Admin email (optional)

# Exit on error
set -e

# Create a file to store database connection details
cat >/root/pausatf_db_info.txt <<EOF
Host: ${db_host}
User: ${db_user}
Password: ${db_password}
Databases: wordpress_dev, wordpress_stage, wordpress_prod
EOF

# Set permissions
chmod 600 /root/pausatf_db_info.txt

# Setup SSH key for server-to-server communication
echo "Setting up SSH key for server-to-server communication..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Generate SSH key if it doesn't exist
if [ ! -f /root/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" -C "wordpress-migration-key"
  chmod 600 /root/.ssh/id_rsa
  chmod 644 /root/.ssh/id_rsa.pub
fi

# Add the public key to authorized_keys
cat /root/.ssh/id_rsa.pub >>/root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Display the public key for manual addition to old server
echo "SSH public key for migration (add to old server's authorized_keys):"
cat /root/.ssh/id_rsa.pub

# Configure SSH client for non-interactive connections
cat >/root/.ssh/config <<EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  LogLevel ERROR
EOF
chmod 600 /root/.ssh/config

# Install and configure Postfix for Gmail SMTP relay
echo "Installing and configuring Postfix for Gmail SMTP relay..."
export DEBIAN_FRONTEND=noninteractive

# Install required packages
apt-get update
apt-get install -y postfix mailutils libsasl2-modules

# Backup original configuration
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak

# Configure Postfix for Gmail SMTP relay
cat >/etc/postfix/main.cf <<EOF
# Postfix configuration for Gmail SMTP relay
smtpd_banner = \$myhostname ESMTP \$mail_name
biff = no
append_dot_mydomain = no
readme_directory = no
compatibility_level = 2

# TLS parameters
smtpd_tls_cert_file = /etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file = /etc/ssl/private/ssl-cert-snakeoil.key
smtpd_tls_security_level = may
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache

# SMTP relay settings
relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_use_tls = yes

# General settings
myhostname = ${domain_name}
myorigin = ${domain_name}
mydestination = \$myhostname, localhost.\$mydomain, localhost
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all
EOF

# Create SASL password file
# Note: smtp_user and smtp_password are optional and may not be provided
# We'll add them to the template call in wordpress.tf if needed
if [ -n "$smtp_user" ] && [ -n "$smtp_password" ]; then
  # SMTP credentials are provided
  cat >/etc/postfix/sasl_passwd <<EOF
[smtp.gmail.com]:587 "$smtp_user":"$smtp_password"
EOF
else
  # SMTP credentials not provided
  echo "# SMTP credentials not provided" >/etc/postfix/sasl_passwd
fi

# Set permissions and create hash database
chmod 600 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

# Reload Postfix configuration
systemctl restart postfix

# Test email configuration if admin_email is provided
if [ -n "$admin_email" ]; then
  echo "Testing email configuration..."
  echo "This is a test email from your WordPress server" | mail -s "WordPress Server Setup Complete" "$admin_email"
else
  echo "Skipping email test as admin_email is not provided"
fi

# Install WP-CLI
echo "Installing WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Mount the PAUSATF WordPress data volume
mkdir -p /mnt/wordpress-data
mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_pausatf-wordpress-data /mnt/wordpress-data

# Add mount to fstab to ensure it's mounted on reboot
if ! grep -q "/mnt/wordpress-data" /etc/fstab; then
  echo "/dev/disk/by-id/scsi-0DO_Volume_pausatf-wordpress-data /mnt/wordpress-data ext4 discard,defaults,noatime 0 2" >> /etc/fstab
fi

# Create directories for each environment
mkdir -p /var/www/dev
mkdir -p /var/www/stage
mkdir -p /var/www/prod

# Clone the default WordPress installation to each environment
cp -r /var/www/html/wordpress/* /var/www/dev/
cp -r /var/www/html/wordpress/* /var/www/stage/
cp -r /var/www/html/wordpress/* /var/www/prod/

# Configure wp-config.php for each environment
# DEV Environment
cat >/var/www/dev/wp-config.php <<EOF
<?php
/**
 * WordPress Configuration for Development Environment
 */

// ** Database settings ** //
define( 'DB_NAME', 'wordpress_dev' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${db_host}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 */
define( 'AUTH_KEY',         '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'SECURE_AUTH_KEY',  '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'LOGGED_IN_KEY',    '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'NONCE_KEY',        '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'AUTH_SALT',        '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'SECURE_AUTH_SALT', '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'LOGGED_IN_SALT',   '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'NONCE_SALT',       '$(openssl rand -base64 64 | tr -d "\n")' );

/**#@-*/

/**
 * WordPress database table prefix.
 */
\$table_prefix = 'wp_dev_';

/**
 * For developers: WordPress debugging mode.
 */
define( 'WP_DEBUG', true );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

# STAGE Environment
cat >/var/www/stage/wp-config.php <<EOF
<?php
/**
 * WordPress Configuration for Staging Environment
 */

// ** Database settings ** //
define( 'DB_NAME', 'wordpress_stage' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${db_host}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 */
define( 'AUTH_KEY',         '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'SECURE_AUTH_KEY',  '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'LOGGED_IN_KEY',    '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'NONCE_KEY',        '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'AUTH_SALT',        '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'SECURE_AUTH_SALT', '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'LOGGED_IN_SALT',   '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'NONCE_SALT',       '$(openssl rand -base64 64 | tr -d "\n")' );

/**#@-*/

/**
 * WordPress database table prefix.
 */
\$table_prefix = 'wp_stage_';

/**
 * For developers: WordPress debugging mode.
 */
define( 'WP_DEBUG', false );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

# PROD Environment
cat >/var/www/prod/wp-config.php <<EOF
<?php
/**
 * WordPress Configuration for Production Environment
 */

// ** Database settings ** //
define( 'DB_NAME', 'wordpress_prod' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${db_host}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 */
define( 'AUTH_KEY',         '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'SECURE_AUTH_KEY',  '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'LOGGED_IN_KEY',    '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'NONCE_KEY',        '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'AUTH_SALT',        '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'SECURE_AUTH_SALT', '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'LOGGED_IN_SALT',   '$(openssl rand -base64 64 | tr -d "\n")' );
define( 'NONCE_SALT',       '$(openssl rand -base64 64 | tr -d "\n")' );

/**#@-*/

/**
 * WordPress database table prefix.
 */
\$table_prefix = 'wp_prod_';

/**
 * For developers: WordPress debugging mode.
 */
define( 'WP_DEBUG', false );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

# Set proper permissions for all environments
chown -R www-data:www-data /var/www/dev
chown -R www-data:www-data /var/www/stage
chown -R www-data:www-data /var/www/prod
chmod 640 /var/www/dev/wp-config.php
chmod 640 /var/www/stage/wp-config.php
chmod 640 /var/www/prod/wp-config.php

# Configure OpenLiteSpeed virtual hosts
# Create virtual host configuration directory if it doesn't exist
mkdir -p /usr/local/lsws/conf/vhosts/dev
mkdir -p /usr/local/lsws/conf/vhosts/stage
mkdir -p /usr/local/lsws/conf/vhosts/prod

# DEV Virtual Host Configuration
cat >/usr/local/lsws/conf/vhosts/dev/vhconf.conf <<EOF
docRoot                   \$VH_ROOT
vhDomain                  dev.pausatf.com
adminEmails               admin@pausatf.com
enableGzip                1
enableIpGeo               0

index  {
  useServer               0
  indexFiles              index.php index.html
}

rewrite  {
  enable                  1
  rules                   <<<END_rules
rewriteEngine             on
rewriteCond %%{REQUEST_FILENAME} !-f
rewriteCond %%{REQUEST_FILENAME} !-d
rewriteRule . /index.php [L]
  END_rules
}

context / {
  location                \$VH_ROOT
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                  1
    inherit                 1
  }
}

context /wp-admin/ {
  location                \$VH_ROOT/wp-admin/
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                  1
    inherit                 1
  }
}
EOF

# STAGE Virtual Host Configuration
cat >/usr/local/lsws/conf/vhosts/stage/vhconf.conf <<EOF
docRoot                   \$VH_ROOT
vhDomain                  stage.pausatf.com
adminEmails               admin@pausatf.com
enableGzip                1
enableIpGeo               0

index  {
  useServer               0
  indexFiles              index.php index.html
}

rewrite  {
  enable                  1
  rules                   <<<END_rules
rewriteEngine             on
rewriteCond %%{REQUEST_FILENAME} !-f
rewriteCond %%{REQUEST_FILENAME} !-d
rewriteRule . /index.php [L]
  END_rules
}

context / {
  location                \$VH_ROOT
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                  1
    inherit                 1
  }
}

context /wp-admin/ {
  location                \$VH_ROOT/wp-admin/
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                  1
    inherit                 1
  }
}
EOF

# PROD Virtual Host Configuration
cat >/usr/local/lsws/conf/vhosts/prod/vhconf.conf <<EOF
docRoot                   \$VH_ROOT
vhDomain                  www.pausatf.com pausatf.com
adminEmails               admin@pausatf.com
enableGzip                1
enableIpGeo               0

index  {
  useServer               0
  indexFiles              index.php index.html
}

rewrite  {
  enable                  1
  rules                   <<<END_rules
rewriteEngine             on
rewriteCond %%{REQUEST_FILENAME} !-f
rewriteCond %%{REQUEST_FILENAME} !-d
rewriteRule . /index.php [L]
  END_rules
}

context / {
  location                \$VH_ROOT
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                  1
    inherit                 1
  }
}

context /wp-admin/ {
  location                \$VH_ROOT/wp-admin/
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                  1
    inherit                 1
  }
}
EOF

# Update the main OpenLiteSpeed configuration to include the virtual hosts
cat >/usr/local/lsws/conf/httpd_config.conf.tmp <<EOF
# OpenLiteSpeed Configuration for PAUSATF Multi-Environment WordPress

serverName                PAUSATF-WordPress
user                      nobody
group                     nogroup
priority                  0
inMemBufSize              60M
swappingDir               /tmp/lshttpd/swap
autoFix503                1
gracefulRestartTimeout    300
mime                      conf/mime.properties
showVersionNumber         0
adminEmails               admin@pausatf.com

errorlog logs/error.log {
  logLevel                DEBUG
  debugLevel              0
  rollingSize             10M
  enableStderrLog         1
}

accesslog logs/access.log {
  rollingSize             10M
  keepDays                30
  compressArchive         0
}

indexFiles                index.html, index.php

expires  {
  enableExpires           1
  expiresByType           image/*=A604800,text/css=A604800,application/x-javascript=A604800,application/javascript=A604800,font/*=A604800,application/x-font-ttf=A604800
}

tuning  {
  maxConnections          10000
  maxSSLConnections       10000
  connTimeout             300
  maxKeepAliveReq         10000
  keepAliveTimeout        5
  sndBufSize              0
  rcvBufSize              0
  maxReqURLLen            8192
  maxReqHeaderSize        16384
  maxReqBodySize          2047M
  maxDynRespHeaderSize    8192
  maxDynRespSize          2047M
  maxCachedFileSize       4096
  totalInMemCacheSize     20M
  maxMMapFileSize         256K
  totalMMapCacheSize      40M
  useSendfile             1
  fileETag                28
  enableGzipCompress      1
  compressibleTypes       default
  enableDynGzipCompress   1
  gzipCompressLevel       6
  gzipAutoUpdateStatic    1
  gzipStaticCompressLevel 6
  gzipMaxFileSize         10M
  gzipMinFileSize         300
}

fileAccessControl  {
  followSymbolLink        1
  checkSymbolLink         0
  requiredPermissionMask  000
  restrictedPermissionMask 000
}

perClientConnLimit  {
  staticReqPerSec         0
  dynReqPerSec            0
  outBandwidth            0
  inBandwidth             0
  softLimit               10000
  hardLimit               10000
  gracePeriod             15
  banPeriod               300
}

CGIRLimit  {
  maxCGIInstances         20
  minUID                  11
  minGID                  10
  priority                0
  CPUSoftLimit            10
  CPUHardLimit            50
  memSoftLimit            1460M
  memHardLimit            1470M
  procSoftLimit           400
  procHardLimit           450
}

accessDenyDir  {
  dir                     /
  dir                     /etc/*
  dir                     /dev/*
  dir                     conf/*
  dir                     admin/conf/*
}

accessControl  {
  allow                   ALL
}

extprocessor lsphp {
  type                    lsapi
  address                 uds://tmp/lshttpd/lsphp.sock
  maxConns                35
  env                     PHP_LSAPI_CHILDREN=35
  env                     LSAPI_AVOID_FORK=200M
  initTimeout             60
  retryTimeout            0
  persistConn             1
  respBuffer              0
  autoStart               1
  path                    fcgi-bin/lsphp
  backlog                 100
  instances               1
  priority                0
  memSoftLimit            2047M
  memHardLimit            2047M
  procSoftLimit           400
  procHardLimit           500
}

scripthandler  {
  add                     lsapi:lsphp php
}

railsDefaults  {
  maxConns                1
  env                     LSAPI_MAX_IDLE=60
  initTimeout             60
  retryTimeout            0
  pcKeepAliveTimeout      60
  respBuffer              0
  backlog                 50
  runOnStartUp            3
  extMaxIdleTime          300
  priority                3
  memSoftLimit            2047M
  memHardLimit            2047M
  procSoftLimit           500
  procHardLimit           600
}

virtualHost dev {
  vhRoot                  /var/www/dev
  configFile              conf/vhosts/dev/vhconf.conf
  allowSymbolLink         1
  enableScript            1
  restrained              1
  setUIDMode              0
}

virtualHost stage {
  vhRoot                  /var/www/stage
  configFile              conf/vhosts/stage/vhconf.conf
  allowSymbolLink         1
  enableScript            1
  restrained              1
  setUIDMode              0
}

virtualHost prod {
  vhRoot                  /var/www/prod
  configFile              conf/vhosts/prod/vhconf.conf
  allowSymbolLink         1
  enableScript            1
  restrained              1
  setUIDMode              0
}

listener Default {
  address                 *:80
  secure                  0
  map                     dev dev.pausatf.com
  map                     stage stage.pausatf.com
  map                     prod www.pausatf.com, pausatf.com
}

listener SSL {
  address                 *:443
  secure                  1
  keyFile                 /usr/local/lsws/admin/conf/webadmin.key
  certFile                /usr/local/lsws/admin/conf/webadmin.crt
  map                     dev dev.pausatf.com
  map                     stage stage.pausatf.com
  map                     prod www.pausatf.com, pausatf.com
}

vhTemplate centralConfigLog {
  templateFile            conf/templates/ccl.conf
  listeners               Default
}

vhTemplate EasyRailsWithSuEXEC {
  templateFile            conf/templates/rails.conf
  listeners               Default
}
EOF

# Backup the original configuration
cp /usr/local/lsws/conf/httpd_config.conf /usr/local/lsws/conf/httpd_config.conf.bak

# Replace the configuration
mv /usr/local/lsws/conf/httpd_config.conf.tmp /usr/local/lsws/conf/httpd_config.conf

# Create databases for each environment
mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" -e "CREATE DATABASE IF NOT EXISTS wordpress_dev;"
mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" -e "CREATE DATABASE IF NOT EXISTS wordpress_stage;"
mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" -e "CREATE DATABASE IF NOT EXISTS wordpress_prod;"

# Restart OpenLiteSpeed
systemctl restart lsws

echo "PAUSATF OpenLiteSpeed WordPress Multi-Environment configuration completed successfully!"
echo "Access your environments at:"
echo "- Development: http://dev.pausatf.com"
echo "- Staging: http://stage.pausatf.com"
echo "- Production: http://www.pausatf.com"
echo "OpenLiteSpeed WebAdmin Console: https://$(hostname -I | awk '{print $1}'):7080"
