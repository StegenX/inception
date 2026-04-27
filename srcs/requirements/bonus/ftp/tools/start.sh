#!/bin/bash

# Create FTP user for WordPress access
FTP_USER=${FTP_USER:-ftpuser}
FTP_PASSWORD=$(cat /run/secrets/ftp_password 2>/dev/null || echo "ftppass")

# Add FTP user if doesn't exist
if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -s /bin/false -d /var/www/wordpress "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    chown "$FTP_USER:$FTP_USER" /var/www/wordpress
    echo "FTP user '$FTP_USER' created"
fi

# Ensure correct permissions
chown -R "$FTP_USER:$FTP_USER" /var/www/wordpress
chmod 755 /var/www/wordpress

# Start vsftpd in foreground
exec /usr/sbin/vsftpd /etc/vsftpd.conf
