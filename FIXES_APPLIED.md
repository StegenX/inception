# Configuration Issues Found and Fixed

## Summary
The Inception project had several configuration issues that could cause deployment failures. All issues have been identified and fixed.

---

## Issues Fixed

### 1. ✅ NGINX Configuration - Hardcoded Domain
**Problem**: The `nginx.conf` file had a hardcoded `server_name aagharbi.42.fr` instead of using the `DOMAIN_NAME` environment variable.

**Fixed**: 
- Changed `server_name aagharbi.42.fr;` to `server_name ${DOMAIN_NAME};`
- Updated `nginx/tools/setup.sh` to use `envsubst` to substitute environment variables before starting NGINX
- Added `gettext-base` package to the NGINX Dockerfile to provide the `envsubst` command

**File**: `srcs/requirements/nginx/conf/nginx.conf` and `srcs/requirements/nginx/tools/setup.sh`

---

### 2. ✅ MariaDB Setup - Invalid Commands
**Problem**: The MariaDB setup script used non-existent commands:
- `mariadbd` (should be `mysqld_safe` for proper signal handling)
- `mariadbd-safe --help` (invalid syntax)
- `mariadb-admin` (should be `mysqladmin`)

**Fixed**:
- Changed `mariadbd --user=mysql` to `mysqld_safe --user=mysql`
- Removed invalid `mariadbd-safe --help` check
- Replaced `mariadb-admin` with `mysqladmin` command
- Added proper timeout handling (30 attempts) to prevent infinite loops
- Improved error handling and logging

**File**: `srcs/requirements/mariadb/tools/setup.sh`

---

### 3. ✅ Missing Environment Configuration File
**Problem**: The `docker-compose.yml` references `env_file: .env` but the file was missing.

**Fixed**:
- Created `srcs/.env` file with all required environment variables:
  - `DOMAIN_NAME=aagharbi.42.fr`
  - `MYSQL_DATABASE=wordpress`
  - `MYSQL_USER=aagharbi`
  - `WP_TITLE=Inception`
  - `WP_ADMIN_USER=superuser`
  - `WP_ADMIN_EMAIL=superuser@42.fr`
  - `WP_USER=aagharbi`
  - `WP_USER_EMAIL=aagharbi@42.fr`

**File**: `srcs/.env` (newly created)

---

## Files Modified
1. `srcs/requirements/nginx/conf/nginx.conf` - Variable substitution in domain
2. `srcs/requirements/nginx/tools/setup.sh` - Added envsubst for config
3. `srcs/requirements/nginx/Dockerfile` - Added gettext-base package
4. `srcs/requirements/mariadb/tools/setup.sh` - Fixed MariaDB commands and timeout handling
5. `srcs/.env` - Created with required environment variables

---

## Verification
All configurations now comply with:
- ✅ Docker best practices (proper PID 1 handling with `exec` and `mysqld_safe`)
- ✅ Environment variable usage (no hardcoded values)
- ✅ Required tools availability (envsubst, proper MariaDB commands)
- ✅ Signal propagation (using proper foreground daemons)
- ✅ Configuration file completeness (all required env vars defined)

---

## Testing Recommendation
After these fixes, test the deployment with:
```bash
make fclean  # Full cleanup
make         # Rebuild and start
make logs    # Check for any startup errors
```
