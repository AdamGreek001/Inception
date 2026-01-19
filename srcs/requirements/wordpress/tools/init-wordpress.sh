#!/bin/bash

mkdir -p /run/php
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

cd /var/www/html

WP_ADMIN_PASS=$(cat /run/secrets/credentials | cut -d':' -f2)
DB_PASS=$(cat /run/secrets/db_password)
WP_USER_PASS="editorPass123!"

if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASS}" \
        --allow-root
fi

sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

exec php-fpm8.2 -F
