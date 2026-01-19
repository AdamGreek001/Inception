# Developer Documentation

*Technical documentation for developers working on the Inception project.*

---

## Environment Setup

### Prerequisites

1. **Operating System**: Linux (or VM running Linux)
2. **Docker**: Version 20.10 or higher
3. **Docker Compose**: Version 2.0 or higher (integrated with Docker)

### Installation

**Docker Installation (Debian/Ubuntu)**:
```bash
# Update packages
sudo apt update

# Install Docker
sudo apt install docker.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes (or logout/login)
newgrp docker

# Verify installation
docker --version
docker compose version
```

---

## Configuration Files

### Environment Variables (`.env`)

Location: `srcs/.env`

```bash
DOMAIN_NAME=eel-alao.42.fr      # Your domain
MYSQL_DATABASE=wordpress         # Database name
MYSQL_USER=wpuser               # Database user
WP_TITLE=Inception              # WordPress site title
WP_ADMIN_USER=supervisor        # Admin username (no "admin"!)
WP_ADMIN_EMAIL=supervisor@student.42.fr
WP_USER=editor                  # Second user
WP_USER_EMAIL=editor@student.42.fr
```

### Secrets Files

Location: `secrets/`

| File | Purpose |
|------|---------|
| `db_password.txt` | MariaDB WordPress user password |
| `db_root_password.txt` | MariaDB root password |
| `credentials.txt` | WordPress admin credentials (format: `user:password`) |

**Creating Secrets**:
```bash
# Database passwords
echo 'your_secure_password' > secrets/db_password.txt
echo 'your_root_password' > secrets/db_root_password.txt

# WordPress admin (username:password format)
echo 'supervisor:your_admin_password' > secrets/credentials.txt
```

---

## Building the Project

### Complete Build

```bash
# Build all images and start containers
make

# Or step by step:
make build  # Build images only
make up     # Start containers
```

### Individual Container Build

```bash
# Build specific service
docker compose -f srcs/docker-compose.yml build mariadb
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml build nginx
```

### Force Rebuild (No Cache)

```bash
docker compose -f srcs/docker-compose.yml build --no-cache
```

---

## Container Management

### Starting Containers

```bash
make up
# Or:
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d
```

### Stopping Containers

```bash
make down
# Or:
docker compose -f srcs/docker-compose.yml --env-file srcs/.env down
```

### Viewing Container Status

```bash
make status
# Or:
docker ps -a
```

### Viewing Logs

```bash
# All containers
make logs

# Follow logs
make logs-f

# Specific container
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow specific container
docker logs -f wordpress
```

### Entering Container Shell

```bash
make shell-nginx
make shell-wordpress
make shell-mariadb

# Or manually:
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
```

### Restarting Containers

```bash
make restart
# Or individual:
docker restart nginx
docker restart wordpress
docker restart mariadb
```

---

## Project Architecture

### Directory Structure

```
Inception/
├── Makefile                           # Build automation
├── .gitignore                         # Git ignore rules
├── README.md                          # Main documentation
├── USER_DOC.md                        # User documentation
├── DEV_DOC.md                         # This file
├── secrets/                           # Sensitive data (gitignored)
│   ├── credentials.txt                # user:password
│   ├── db_password.txt                # DB user password
│   └── db_root_password.txt           # DB root password
└── srcs/
    ├── .env                           # Environment variables
    ├── docker-compose.yml             # Container orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile             # MariaDB image definition
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── 50-server.cnf      # MariaDB configuration
        │   └── tools/
        │       └── init-db.sh         # Database initialization
        ├── nginx/
        │   ├── Dockerfile             # NGINX image definition
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf         # NGINX configuration
        │   └── tools/
        │       └── setup.sh           # SSL generation + startup
        └── wordpress/
            ├── Dockerfile             # WordPress image definition
            ├── .dockerignore
            ├── conf/
            │   └── www.conf           # PHP-FPM pool configuration
            └── tools/
                └── init-wordpress.sh  # WordPress installation
```

### Container Communication

```
┌──────────────────────────────────────────────────────────────────┐
│                        inception network                          │
│                                                                   │
│   ┌─────────┐         ┌─────────────┐         ┌─────────────┐   │
│   │  nginx  │ ──────► │  wordpress  │ ──────► │  mariadb    │   │
│   │  :443   │ FastCGI │   :9000     │  MySQL  │   :3306     │   │
│   └────┬────┘         └─────────────┘         └─────────────┘   │
│        │                     │                       │           │
└────────┼─────────────────────┼───────────────────────┼───────────┘
         │                     │                       │
    ┌────▼────┐          ┌─────▼─────┐          ┌─────▼─────┐
    │  Port   │          │  Volume   │          │  Volume   │
    │   443   │          │ wordpress │          │ mariadb   │
    │(exposed)│          │   _data   │          │   _data   │
    └─────────┘          └───────────┘          └───────────┘
```

---

## Data Persistence

### Volume Locations

| Volume | Container Path | Host Path |
|--------|---------------|-----------|
| `wordpress_data` | `/var/www/html` | `/home/eel-alao/data/wordpress` |
| `mariadb_data` | `/var/lib/mysql` | `/home/eel-alao/data/mariadb` |

### Creating Data Directories

```bash
sudo mkdir -p /home/eel-alao/data/wordpress
sudo mkdir -p /home/eel-alao/data/mariadb
sudo chown -R $(whoami):$(whoami) /home/eel-alao/data
```

### Data Backup

```bash
# Backup WordPress files
sudo tar -czf wordpress_files_$(date +%Y%m%d).tar.gz \
    /home/eel-alao/data/wordpress

# Backup database
docker exec mariadb mysqldump -u root \
    -p"$(cat secrets/db_root_password.txt)" \
    wordpress > wordpress_db_$(date +%Y%m%d).sql
```

### Data Restore

```bash
# Restore WordPress files
sudo tar -xzf wordpress_files_YYYYMMDD.tar.gz -C /

# Restore database
docker exec -i mariadb mysql -u root \
    -p"$(cat secrets/db_root_password.txt)" \
    wordpress < wordpress_db_YYYYMMDD.sql
```

---

## Debugging

### Common Issues

#### Container Won't Start

```bash
# Check logs
docker logs <container_name>

# Check if ports are in use
sudo netstat -tlnp | grep 443
sudo netstat -tlnp | grep 3306
```

#### MariaDB Connection Refused

1. Wait for MariaDB healthcheck to pass
2. Check MariaDB logs: `docker logs mariadb`
3. Verify secrets files exist and have correct content

#### WordPress Installation Fails

1. Check if MariaDB is healthy: `docker ps`
2. Verify database credentials in `.env` match secrets
3. Check WordPress logs: `docker logs wordpress`

#### NGINX 502 Bad Gateway

1. Check if WordPress container is running
2. Verify PHP-FPM is listening on port 9000
3. Check NGINX logs: `docker logs nginx`

### Debug Commands

```bash
# Check container processes
docker exec wordpress ps aux

# Test database connection from WordPress
docker exec wordpress sh -c 'mariadb-admin ping -h mariadb'

# Test PHP-FPM
docker exec wordpress sh -c 'php -v'

# Check NGINX configuration
docker exec nginx nginx -t

# Verify network connectivity
docker exec wordpress ping -c 3 mariadb
docker exec nginx ping -c 3 wordpress
```

---

## Cleanup

### Stop and Remove Containers

```bash
make down
```

### Remove Containers, Images, and Volumes

```bash
make clean
```

### Full Reset (Including Data)

```bash
make fclean
```

### Manual Cleanup

```bash
# Remove containers
docker compose -f srcs/docker-compose.yml down

# Remove images
docker rmi $(docker images -q "*:inception") 2>/dev/null || true

# Remove volumes
docker volume rm wordpress_data mariadb_data 2>/dev/null || true

# Remove data directories
sudo rm -rf /home/eel-alao/data

# Prune system
docker system prune -af
```

---

## Testing

### Health Checks

```bash
# Check all containers are running
docker ps --format "table {{.Names}}\t{{.Status}}"

# Verify HTTPS works
curl -k -I https://eel-alao.42.fr

# Verify WordPress is responding
curl -k https://eel-alao.42.fr | grep -i wordpress
```

### Network Testing

```bash
# Test container DNS resolution
docker exec nginx ping -c 1 wordpress
docker exec wordpress ping -c 1 mariadb

# Test port connectivity
docker exec nginx nc -zv wordpress 9000
docker exec wordpress nc -zv mariadb 3306
```

### SSL Certificate Verification

```bash
# Check SSL certificate details
echo | openssl s_client -connect eel-alao.42.fr:443 2>/dev/null | \
    openssl x509 -noout -text | head -20
```

---

## Modification Guide

### Changing Domain Name

1. Update `srcs/.env`:
   ```bash
   DOMAIN_NAME=newdomain.42.fr
   ```

2. Update `srcs/requirements/nginx/conf/nginx.conf`:
   ```nginx
   server_name newdomain.42.fr;
   ```

3. Update SSL generation in `srcs/requirements/nginx/tools/setup.sh`:
   ```bash
   -subj "/C=MA/.../CN=newdomain.42.fr"
   ```

4. Rebuild: `make re`

### Adding New PHP Extensions

Edit `srcs/requirements/wordpress/Dockerfile`:
```dockerfile
RUN apk add --no-cache \
    php82 \
    php82-newextension \  # Add new extension
    ...
```

### Modifying MariaDB Configuration

Edit `srcs/requirements/mariadb/conf/50-server.cnf` and rebuild:
```bash
make re
```

---

## Resources

- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Alpine Package Search](https://pkgs.alpinelinux.org/packages)
- [NGINX Configuration Guide](https://nginx.org/en/docs/beginners_guide.html)
- [MariaDB Docker Reference](https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/)
- [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
