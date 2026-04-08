# User Documentation — Inception

## Services Overview

This stack provides the following services:

| Service | Description | Container |
|---|---|---|
| **NGINX** | Reverse proxy with TLS (HTTPS only, port 443) | `nginx` |
| **WordPress** | CMS with PHP-FPM 8.2 | `wordpress` |
| **MariaDB** | Relational database for WordPress data | `mariadb` |

All traffic enters through NGINX on port 443 using TLSv1.2 or TLSv1.3.

## Starting and Stopping

```bash
# Start all services (builds images if needed)
make

# Stop all services (keeps data)
make down

# Stop without removing containers
make stop

# Start stopped containers
make start

# Complete cleanup (removes everything including data)
make fclean

# Rebuild from scratch
make re
```

## Accessing the Website

1. Ensure `stegen.42.fr` resolves to your machine:
   ```bash
   echo "127.0.0.1 stegen.42.fr" | sudo tee -a /etc/hosts
   ```

2. Open your browser and go to: **https://stegen.42.fr**
   - Accept the self-signed certificate warning

3. WordPress Admin Panel: **https://stegen.42.fr/wp-admin**

## Credentials

| Account | Username | Password Location |
|---|---|---|
| WordPress Admin | `superuser` | `secrets/credentials.txt` |
| WordPress User | `stegen` | Same as DB password in `secrets/db_password.txt` |
| MariaDB User | `stegen` | `secrets/db_password.txt` |
| MariaDB Root | `root` | `secrets/db_root_password.txt` |

> **Note**: Never commit the `secrets/` directory to Git. It is excluded via `.gitignore`.

## Checking Service Health

```bash
# View container status
make status

# View real-time logs
make logs

# Check individual container
docker logs nginx
docker logs wordpress
docker logs mariadb

# Test NGINX TLS
curl -k https://stegen.42.fr

# Test MariaDB connection
docker exec mariadb mariadb -u stegen -p<password> wordpress -e "SHOW TABLES;"
```
