#!/bin/bash

# Start PHP built-in server for Adminer
# Adminer serves on port 8080 inside container
php -S 0.0.0.0:8080 -t /var/www/adminer
