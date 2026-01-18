#!/bin/sh
# WordPress Initialization Script for Inception

set -e

# Read secrets from files
WP_ADMIN_PASS=$(cat /run/secrets/credentials | cut -d':' -f2)
DB_PASS=$(cat /run/secrets/db_password)
WP_USER_PASS="editorPass123!"

# Create log directory
mkdir -p /var/log/php82
chown nobody:nobody /var/log/php82

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mariadb-admin ping -h mariadb -u "${MYSQL_USER}" -p"${DB_PASS}" --silent 2>/dev/null; do
    echo "MariaDB is not ready yet, waiting..."
    sleep 2
done
echo "MariaDB is ready!"

# Download WordPress if not present
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."
    
    # Download WordPress
    wp core download --allow-root --path=/var/www/html
    
    echo "Configuring WordPress..."
    
    # Create wp-config.php
    wp config create \
        --allow-root \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost="mariadb:3306" \
        --dbcharset="utf8mb4"
    
    echo "Installing WordPress..."
    
    # Install WordPress
    wp core install \
        --allow-root \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email
    
    echo "Creating additional user..."
    
    # Create second user (project requirement)
    wp user create \
        --allow-root \
        --path=/var/www/html \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASS}"
    
    # Set proper permissions
    chown -R nobody:nobody /var/www/html
    chmod -R 755 /var/www/html
    
    echo "WordPress installation complete!"
else
    echo "WordPress already installed, skipping setup."
fi

echo "Starting PHP-FPM..."
exec php-fpm82 -F
