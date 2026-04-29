#!/bin/bash

# Read secrets
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Wait for MariaDB to be ready and accepting connections
echo "Waiting for MariaDB..."
until mariadb -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" "${MYSQL_DATABASE}" > /dev/null 2>&1; do
    echo "  MariaDB not ready yet, retrying in 3s..."
    sleep 3
done
echo "MariaDB is ready!"

# Download and configure WordPress if not already done
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Setting up WordPress..."

    # Download WordPress core
    wp core download --allow-root --path=/var/www/wordpress

    # Create wp-config.php
    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb:3306 \
        --path=/var/www/wordpress

    # Install WordPress
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path=/var/www/wordpress

    # Create second user (non-admin)
    wp user create --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${MYSQL_PASSWORD}" \
        --path=/var/www/wordpress

    # Configure Redis Cache
    wp config set WP_CACHE true --raw --allow-root --path=/var/www/wordpress
    wp config set WP_REDIS_HOST redis --allow-root --path=/var/www/wordpress
    wp config set WP_REDIS_PORT 6379 --raw --allow-root --path=/var/www/wordpress
    
    # Install and activate Redis Object Cache plugin
    wp plugin install redis-cache --activate --allow-root --path=/var/www/wordpress

    echo "WordPress setup complete!"
fi

# Install Redis drop-in if plugin exists but drop-in isn't installed
if [ -f /var/www/wordpress/wp-content/plugins/redis-cache/includes/object-cache.php ] && [ ! -f /var/www/wordpress/wp-content/object-cache.php ]; then
    cp /var/www/wordpress/wp-content/plugins/redis-cache/includes/object-cache.php /var/www/wordpress/wp-content/object-cache.php
    echo "Redis object-cache drop-in installed!"
fi

# Final permission fix
chown -R www-data:www-data /var/www/wordpress
chmod 644 /var/www/wordpress/wp-content/object-cache.php 2>/dev/null || true

# Start PHP-FPM in foreground (PID 1)
exec php-fpm8.2 -F
