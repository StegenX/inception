# Developer Documentation — Inception

## Environment Setup from Scratch

### Prerequisites

- Linux (Debian/Ubuntu recommended)
- Docker Engine 20.10+
- Docker Compose v2 (comes with `docker-ce`)
- `make`, `openssl`

### Installation (if Docker is not installed)

```bash
# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Configuration Files

| File | Purpose |
|---|---|
| `srcs/.env` | Non-secret environment variables (domain, usernames, DB name) |
| `secrets/credentials.txt` | WordPress admin password |
| `secrets/db_password.txt` | MariaDB user password |
| `secrets/db_root_password.txt` | MariaDB root password |

### DNS Setup

```bash
echo "127.0.0.1 aagharbi.42.fr" | sudo tee -a /etc/hosts
```

## Building and Launching

```bash
# Build all images and start containers
make

# This runs:
# 1. Creates /home/aagharbi/data/wordpress and /home/aagharbi/data/mariadb
# 2. docker compose -f srcs/docker-compose.yml up -d --build
```

## Managing Containers and Volumes

```bash
# View status
make status

# Stop containers (preserve data)
make down

# Remove containers AND volumes
make clean

# Remove everything + prune Docker cache
make fclean

# Rebuild from scratch
make re

# Follow logs
make logs

# Shell into a container
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

## Container Management Commands

```bash
# Restart a single service
docker compose -f srcs/docker-compose.yml restart nginx

# Rebuild a single service
docker compose -f srcs/docker-compose.yml up -d --build wordpress

# View resource usage
docker stats

# Inspect a volume
docker volume inspect srcs_wp_files
docker volume inspect srcs_db_data
```

## Data Persistence

| Volume | Container Path | Host Path |
|---|---|---|
| `wp_files` | `/var/www/wordpress` | `/home/aagharbi/data/wordpress` |
| `db_data` | `/var/lib/mysql` | `/home/aagharbi/data/mariadb` |

Both volumes use the `local` driver with `bind` option to map named Docker volumes to specific host directories. Data persists across container restarts and rebuilds. Only `make clean` or `make fclean` deletes the data.

## Architecture

```
                    ┌─────────────┐
   Port 443 ──────>│   NGINX     │
   (TLS 1.2/1.3)   │  (reverse   │
                    │   proxy)    │
                    └──────┬──────┘
                           │ FastCGI :9000
                    ┌──────▼──────┐
                    │  WordPress  │
                    │  + PHP-FPM  │
                    └──────┬──────┘
                           │ MySQL :3306
                    ┌──────▼──────┐
                    │  MariaDB    │
                    └─────────────┘

Network: inception (bridge)
```

## Key Design Decisions

- **Debian Bookworm** as base image (penultimate stable)
- **Docker secrets** for all passwords (mounted at `/run/secrets/`)
- **`exec`** in entrypoints ensures the service runs as PID 1 for proper signal handling
- **No `latest` tag** — all images use explicit version tags
- **`clear_env = no`** in PHP-FPM to pass environment variables through
- **Self-signed SSL** generated at NGINX container startup
- **WP-CLI** for automated WordPress installation (no manual setup needed)
