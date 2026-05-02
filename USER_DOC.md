# User Documentation — Inception

## Services Overview

This stack provides the following services:

| Service | Description | Container | Access |
|---|---|---|---|
| **NGINX** | Reverse proxy with TLS (HTTPS only, port 443) | `nginx` | https://aagharbi.1337.ma |
| **WordPress** | CMS with PHP-FPM 8.2 | `wordpress` | https://aagharbi.1337.ma/wp-admin |
| **MariaDB** | Relational database for WordPress data | `mariadb` | Internal network only |
| **Adminer** *(Bonus)* | Web-based database administration tool | `adminer` | http://aagharbi.1337.ma:8080 |
| **Portainer** *(Bonus)* | Container and infrastructure management GUI | `portainer` | https://aagharbi.1337.ma:9443 |
| **Redis** *(Bonus)* | In-memory caching layer for performance | `redis` | Port 6379 (internal) |
| **FTP** *(Bonus)* | File transfer server for WordPress files | `ftp` | Port 21, 21100-21200 |
| **Website** *(Bonus)* | Static portfolio website (HTML/CSS) | `website` | http://aagharbi.1337.ma:8000 |

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

1. Ensure `aagharbi.1337.ma` resolves to your machine:
   ```bash
   echo "127.0.0.1 aagharbi.1337.ma" | sudo tee -a /etc/hosts
   ```

2. Open your browser and go to: **https://aagharbi.1337.ma**
   - Accept the self-signed certificate warning

3. **WordPress Admin Panel**: https://aagharbi.1337.ma/wp-admin
   - Username: `superuser`
   - Password: Check `secrets/credentials.txt`

4. **Adminer (Bonus)**: http://aagharbi.1337.ma:8080
   - Database management GUI
   - Server: `mariadb`
   - Username: `aagharbi`
   - Password: Check `secrets/db_password.txt`

5. **Portainer (Bonus)**: https://aagharbi.1337.ma:9443
   - Container and infrastructure management
   - Password: Check `secrets/portainer_password.txt`
   - Manage all Docker containers, images, volumes, networks

6. **FTP Server (Bonus)**: ftp://aagharbi.1337.ma:21
   - Username: `ftpuser` (from .env)
   - Password: Check `secrets/ftp_password.txt`
   - Upload/download WordPress files

7. **Portfolio Website (Bonus)**: http://aagharbi.1337.ma:8000
   - Static HTML portfolio showcasing the project

## Credentials

| Account | Username | Password Location |
|---|---|---|
| WordPress Admin | `superuser` | `secrets/credentials.txt` |
| WordPress User | `aagharbi` | Same as DB password in `secrets/db_password.txt` |
| MariaDB User | `aagharbi` | `secrets/db_password.txt` |
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
curl -k https://aagharbi.1337.ma

# Test MariaDB connection
docker exec mariadb mariadb -u aagharbi -p<password> wordpress -e "SHOW TABLES;"
```
