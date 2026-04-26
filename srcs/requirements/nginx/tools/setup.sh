#!/bin/bash

# Substitute environment variables in nginx config
envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/inception.conf > /etc/nginx/conf.d/inception.conf.tmp
mv /etc/nginx/conf.d/inception.conf.tmp /etc/nginx/conf.d/inception.conf

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=MA/ST=Rabat/L=Rabat/O=42/OU=42/CN=${DOMAIN_NAME}"
    echo "SSL certificate generated for ${DOMAIN_NAME}"
fi

# Start nginx in foreground (PID 1)
exec nginx -g "daemon off;"
