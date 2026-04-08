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

    echo "WordPress setup complete!"
fi

# Fix permissions
chown -R www-data:www-data /var/www/wordpress

# Start PHP-FPM in foreground (PID 1)
exec php-fpm8.2 -F
