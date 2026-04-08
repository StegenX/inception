*This project has been created as part of the 42 curriculum by stegen.*

# Inception

## Description

Inception is a system administration project that uses **Docker** to set up a small infrastructure composed of multiple services running in isolated containers. The project orchestrates three core services — **NGINX**, **WordPress + PHP-FPM**, and **MariaDB** — connected through a Docker network, with persistent data stored via named volumes.

### Why Docker?

Docker provides OS-level virtualization through containers — lightweight, portable, self-sufficient units that package code and dependencies together. Unlike virtual machines, containers share the host kernel, making them faster to start and more resource-efficient.

### Key Comparisons

| Concept | Option A | Option B |
|---|---|---|
| **VM vs Docker** | VMs virtualize hardware, each running a full OS. Heavy, slow to boot. | Docker shares the host kernel, containers are lightweight and start in seconds. |
| **Secrets vs Env Vars** | Environment variables are visible in process listings and logs. | Docker secrets are mounted as files in `/run/secrets/`, never exposed in env or logs. |
| **Docker Network vs Host** | Host network shares the host's network stack — no isolation. | Docker bridge network isolates containers, allowing controlled inter-service communication. |
| **Volumes vs Bind Mounts** | Bind mounts map a host path directly — tightly coupled to host filesystem. | Named volumes are managed by Docker, more portable, and support driver options. |

## Instructions

### Prerequisites

- Docker Engine (20.10+)
- Docker Compose v2
- `make`
- `openssl`

### Quick Start

```bash
# Add domain to hosts file (one-time)
echo "127.0.0.1 stegen.42.fr" | sudo tee -a /etc/hosts

# Build and start all services
make

# Check status
make status

# View logs
make logs

# Stop
make down

# Full cleanup (removes volumes and data)
make fclean
```

### Access

- **Website**: https://stegen.42.fr
- **WordPress Admin**: https://stegen.42.fr/wp-admin
  - Admin user: `superuser` (password in `secrets/credentials.txt`)
  - Regular user: `stegen`

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- [WordPress CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [TLS Configuration Guide](https://wiki.mozilla.org/Security/Server_Side_TLS)

### AI Usage

AI was used to assist with:
- Generating boilerplate configuration files (nginx.conf, PHP-FPM pool config)
- Reviewing Docker best practices for PID 1 handling and signal propagation
- Drafting documentation templates

All generated content was reviewed, understood, and adapted to the specific project requirements.
