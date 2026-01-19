# User Documentation

*This documentation explains how to use the Inception web infrastructure.*

---

## Overview

The Inception project provides a complete web hosting stack consisting of:

| Service | Purpose |
|---------|---------|
| **NGINX** | Secure web server handling HTTPS connections |
| **WordPress** | Website content management system |
| **MariaDB** | Database storing all website content |

All communication happens over HTTPS (port 443) ensuring your data is encrypted.

---

## Services Provided

### Website Hosting
- Your WordPress website is accessible at: **https://eel-alao.42.fr**
- The site uses a valid SSL certificate (self-signed for development)
- All traffic is encrypted using TLS 1.2 or TLS 1.3

### Administration Panel
- WordPress admin panel: **https://eel-alao.42.fr/wp-admin**
- Manage posts, pages, themes, plugins, and users
- Full administrative control over your website

### Database
- MariaDB database for WordPress data storage
- Automatic backups through volume persistence
- Data survives container restarts

---

## Starting and Stopping the Project

### Starting the Infrastructure

```bash
# Navigate to project directory
cd /path/to/Inception

# Start all services
make

# Or explicitly:
make up
```

You should see output indicating containers are starting. Wait about 30 seconds for all services to initialize.

### Stopping the Infrastructure

```bash
# Stop all containers (preserves data)
make down
```

### Restarting Services

```bash
# Restart all containers
make restart
```

---

## Accessing the Website

### First-Time Setup

1. **Add domain to your hosts file** (one-time setup):
   ```bash
   echo "127.0.0.1 eel-alao.42.fr" | sudo tee -a /etc/hosts
   ```

2. **Start the infrastructure**:
   ```bash
   make
   ```

3. **Open your browser** and navigate to:
   - Website: https://eel-alao.42.fr
   - Admin: https://eel-alao.42.fr/wp-admin

4. **Accept the security warning** (self-signed certificate)

### Browser Security Warning

Since we use a self-signed SSL certificate, your browser will show a security warning. This is expected for development environments.

- **Chrome**: Click "Advanced" → "Proceed to eel-alao.42.fr (unsafe)"
- **Firefox**: Click "Advanced" → "Accept the Risk and Continue"
- **Safari**: Click "Show Details" → "visit this website"

---

## Credentials

### WordPress Admin Account

| Field | Value |
|-------|-------|
| Username | `supervisor` |
| Password | (see `/secrets/credentials.txt`) |
| Email | supervisor@student.42.fr |

### WordPress Editor Account

| Field | Value |
|-------|-------|
| Username | `editor` |
| Password | `editorPass123!` |
| Email | editor@student.42.fr |

### Locating Credentials

Sensitive credentials are stored in the `secrets/` directory:

```bash
# View WordPress admin password
cat secrets/credentials.txt

# View database password
cat secrets/db_password.txt
```

> ⚠️ **Security Note**: Never commit the `secrets/` directory to version control!

---

## Checking Service Health

### Quick Status Check

```bash
make status
```

This shows all running containers and their current state.

### Detailed Container Information

```bash
# View all containers
docker ps -a

# View container logs
make logs

# Follow logs in real-time (Ctrl+C to exit)
make logs-f
```

### Service-Specific Checks

**NGINX (Web Server)**:
```bash
# Should return HTML content
curl -k https://eel-alao.42.fr

# Check NGINX container
docker logs nginx
```

**WordPress**:
```bash
# Enter WordPress container
make shell-wordpress

# Check PHP-FPM is running
ps aux | grep php
```

**MariaDB (Database)**:
```bash
# Enter MariaDB container
make shell-mariadb

# Test database connection
mysql -u wpuser -p
```

---

## Common Tasks

### Viewing Logs

```bash
# All container logs
make logs

# Specific container logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow logs in real-time
docker logs -f wordpress
```

### Accessing Container Shell

```bash
# NGINX shell
make shell-nginx

# WordPress shell
make shell-wordpress

# MariaDB shell
make shell-mariadb
```

### Restarting a Specific Service

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

---

## Troubleshooting

### Site Not Loading

1. Check if containers are running:
   ```bash
   make status
   ```

2. Check logs for errors:
   ```bash
   make logs
   ```

3. Verify hosts file entry:
   ```bash
   cat /etc/hosts | grep eel-alao
   ```

### Database Connection Issues

1. Check MariaDB is healthy:
   ```bash
   docker logs mariadb
   ```

2. Verify database credentials in `.env`

3. Wait for MariaDB to fully initialize (can take 30+ seconds on first start)

### Permission Errors

```bash
# Fix data directory permissions
sudo chown -R $(whoami):$(whoami) /home/eel-alao/data
```

---

## Data Location

All persistent data is stored on the host machine:

| Data Type | Location |
|-----------|----------|
| WordPress files | `/home/eel-alao/data/wordpress/` |
| Database | `/home/eel-alao/data/mariadb/` |

### Backup Recommendations

```bash
# Backup WordPress files
tar -czf wordpress_backup.tar.gz /home/eel-alao/data/wordpress/

# Backup database
docker exec mariadb mysqldump -u root -p wordpress > backup.sql
```

---

## Getting Help

1. Check container logs: `make logs`
2. Review this documentation
3. Consult the main README.md for technical details
4. Check DEV_DOC.md for developer troubleshooting
