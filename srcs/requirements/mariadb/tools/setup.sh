#!/bin/bash

# Read secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Create log directory
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Always check if our database and user exist, create if not
# Start temporary MariaDB instance for setup
mariadbd --user=mysql &
pid=$!

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
until mariadbd-safe --help > /dev/null 2>&1 && mariadb -u root -e "SELECT 1" > /dev/null 2>&1; do
    sleep 1
done
# Extra wait for socket to be fully ready
sleep 2

echo "Configuring MariaDB..."
mariadb -u root << EOF
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
-- Create database
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
-- Create user with access from any host
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    echo "MariaDB configuration complete!"
else
    echo "MariaDB configuration failed, retrying without password..."
    # Root might already have a password from a previous run
    mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    echo "MariaDB configuration complete (retry)!"
fi

# Stop the temporary instance gracefully
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown 2>/dev/null || \
    mariadb-admin -u root shutdown 2>/dev/null
wait $pid

# Start MariaDB in foreground (PID 1)
exec mariadbd --user=mysql
