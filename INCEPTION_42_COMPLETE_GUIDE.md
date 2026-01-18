# 🚀 INCEPTION 42 - The Complete Guide
### From Zero to Docker Hero | By Your DevOps Mentor

---

## 📖 Table of Contents
1. [The Big Picture](#the-big-picture)
2. [Docker Fundamentals](#docker-fundamentals)
3. [Docker Compose](#docker-compose)
4. [NGINX Web Server](#nginx-web-server)
5. [MariaDB Database](#mariadb-database)
6. [WordPress + PHP-FPM](#wordpress--php-fpm)
7. [Networking & Security](#networking--security)
8. [System Administration](#system-administration)
9. [Project Structure](#project-structure)
10. [Common Pitfalls](#common-pitfalls)

---

## 🎯 The Big Picture

### What is Inception About?

Imagine you're building a **mini data center** on your computer. You need to set up:
- A **web server** (the receptionist who greets visitors)
- A **database** (the filing cabinet storing all information)
- A **website** (WordPress - the actual office where work happens)

**But here's the catch**: Each component must live in its own isolated "apartment" (container), and they can only talk through specific "doors" (networks).

### Real-World Analogy 🏢

Think of your infrastructure as an **apartment building**:
- **NGINX** = Security guard at the entrance (handles HTTPS, routes traffic)
- **WordPress** = The office where employees work (your website)
- **MariaDB** = The secure basement vault (database storage)

Each apartment (container) has:
- Its own utilities (processes)
- Its own furniture (files)
- Connected by hallways (Docker networks)
- Shared storage rooms (volumes)

---

## 🐳 Docker Fundamentals

### What is Docker?

**Non-Technical**: Docker is like a **shipping container** for software. Just like shipping containers can hold anything (cars, clothes, electronics) and be shipped anywhere in the world, Docker containers hold your software and can run anywhere.

**Technical**: Docker is a containerization platform that packages applications with all their dependencies into isolated, portable units.

### Key Concepts

#### 1. **Images vs Containers**

**Analogy**: 
- **Image** = Blueprint of a house 📋
- **Container** = Actual house built from that blueprint 🏠

You can build multiple houses (containers) from the same blueprint (image).

```bash
# Image: The recipe/blueprint
docker build -t my-nginx .

# Container: The actual running instance
docker run -d my-nginx
```

#### 2. **Dockerfile - The Recipe Book**

A Dockerfile is like a **cooking recipe** with step-by-step instructions:

```dockerfile
# Start with a base ingredient (Alpine Linux)
FROM alpine:3.19

# Install tools (like gathering cooking utensils)
RUN apk update && apk add nginx

# Copy your custom files (add your secret sauce)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose a door (port) for visitors
EXPOSE 443

# Start the service (serve the dish)
CMD ["nginx", "-g", "daemon off;"]
```

**Dockerfile Instructions Explained:**

| Instruction | Analogy | Purpose |
|-------------|---------|---------|
| `FROM` | Foundation of a house | Base operating system |
| `RUN` | Construction work | Execute commands during build |
| `COPY/ADD` | Moving furniture in | Copy files from host to image |
| `WORKDIR` | Setting your current room | Change working directory |
| `ENV` | Setting house rules | Environment variables |
| `EXPOSE` | Installing a doorbell | Document which ports to use |
| `CMD` | Default house activity | Main process to run |
| `ENTRYPOINT` | Mandatory house rule | Command that always runs |

#### 3. **The PID 1 Problem** ⚠️

**Critical Concept**: In Docker, your main process becomes PID 1 (Process ID 1).

**Analogy**: PID 1 is like the **building manager**. If the manager leaves, the entire building shuts down.

**Problem**: Some programs don't handle being PID 1 well (they can't clean up properly).

**Solution**:
```dockerfile
# ❌ BAD - Script becomes PID 1
CMD ["./my-script.sh"]

# ✅ GOOD - Use exec to replace shell with actual process
CMD ["exec", "nginx", "-g", "daemon off;"]

# ✅ ALSO GOOD - Direct command
CMD ["nginx", "-g", "daemon off;"]
```

#### 4. **Volumes - Persistent Storage**

**Analogy**: Volumes are like **external hard drives**. When you format your computer (destroy container), the external drive keeps your data safe.

```yaml
volumes:
  - wordpress_data:/var/www/html
  - db_data:/var/lib/mysql
```

**Without volumes**: Your data disappears when the container stops! 💀  
**With volumes**: Your data persists across container restarts! ✅

#### 5. **Networks - Container Communication**

**Analogy**: Networks are like **internal phone systems** in an office building. Containers can call each other by name without knowing exact office numbers.

```yaml
networks:
  inception-net:
    driver: bridge
```

---

## 🎼 Docker Compose

### What is Docker Compose?

**Analogy**: If Docker is building **one house**, Docker Compose is being a **city planner** who coordinates building an entire neighborhood with roads connecting them.

### The docker-compose.yml Structure

Think of it as a **construction blueprint** for your entire infrastructure:

```yaml
version: '3.8'  # Blueprint version

services:  # All the buildings in your city
  nginx:   # Building #1
    build: ./requirements/nginx
    ports:
      - "443:443"
    depends_on:
      - wordpress
    networks:
      - inception-net

  wordpress:  # Building #2
    build: ./requirements/wordpress
    depends_on:
      - mariadb
    networks:
      - inception-net

  mariadb:  # Building #3
    build: ./requirements/mariadb
    networks:
      - inception-net

networks:  # The roads connecting buildings
  inception-net:
    driver: bridge

volumes:  # Shared storage facilities
  wordpress_data:
  db_data:
```

### Key Docker Compose Concepts

#### 1. **depends_on - The Construction Order**

```yaml
depends_on:
  - mariadb  # Build the database first, THEN WordPress
```

**Analogy**: You can't install furniture (WordPress) before building the house (MariaDB).

**⚠️ Important**: `depends_on` only waits for container to START, not be READY. You'll need health checks or init scripts!

#### 2. **Environment Variables - Configuration Secrets**

```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASS}
  MYSQL_DATABASE: ${DB_NAME}
```

**Analogy**: Environment variables are like **sticky notes** with important information that only your container can see.

---

## 🌐 NGINX Web Server

### What is NGINX?

**Analogy**: NGINX is a **highly efficient receptionist + security guard** at a 5-star hotel:
- Greets visitors (receives HTTP requests)
- Checks credentials (SSL/TLS)
- Directs them to correct room (reverse proxy)
- Handles multiple guests simultaneously (high performance)

### NGINX in Inception

Your NGINX container must:
1. **Only listen on port 443 (HTTPS)** - No HTTP!
2. **Use TLSv1.2 or TLSv1.3** - Security requirement
3. **Act as reverse proxy** - Forward requests to WordPress

### Basic NGINX Configuration

```nginx
server {
    # Listen on HTTPS only
    listen 443 ssl;
    listen [::]:443 ssl;
    
    # Your domain name
    server_name yourusername.42.fr;
    
    # SSL Certificate files (like your building's security badge)
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Where your website files live
    root /var/www/html;
    index index.php index.html;
    
    # Handle PHP files (forward to WordPress)
    location ~ \.php$ {
        fastcgi_pass wordpress:9000;  # Talk to WordPress container
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

### SSL/TLS Certificates

**Analogy**: SSL certificates are like **ID badges** that prove your website is legitimate.

**For 42 Project**: You'll create **self-signed certificates** (like making your own ID badge - works for school, not for production).

```bash
# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx.key -out nginx.crt \
  -subj "/C=MA/ST=State/L=City/O=42/CN=yourusername.42.fr"
```

**What each part means:**
- `-x509`: Type of certificate
- `-nodes`: No password protection
- `-days 365`: Valid for 1 year
- `-newkey rsa:2048`: Create 2048-bit RSA key
- `-subj`: Certificate details (Country, State, etc.)

### Reverse Proxy Explained

**Analogy**: NGINX is like a **hotel concierge**:
1. Guest arrives at front desk (port 443)
2. Concierge checks request
3. Directs guest to correct room (WordPress container)
4. Room service (WordPress) prepares response
5. Concierge delivers response back to guest

```
[Browser] --HTTPS--> [NGINX:443] --FastCGI--> [WordPress:9000] ---> [MariaDB:3306]
                        ↑                           ↓
                        └─────── HTML Response ─────┘
```

---

## 🗄️ MariaDB Database

### What is MariaDB?

**Analogy**: MariaDB is like a **massive, organized filing cabinet** with a very smart librarian who can instantly find any document you need.

**Technical**: MariaDB is a fork of MySQL - a relational database management system (RDBMS).

### Why MariaDB for Inception?

- Lightweight and fast
- Compatible with WordPress
- Open-source and free
- Part of 42 project requirements

### Database Concepts Simplified

#### 1. **Database** = The Filing Cabinet
```sql
CREATE DATABASE wordpress_db;
```

#### 2. **Tables** = Individual Drawers
```sql
CREATE TABLE users (
    id INT,
    username VARCHAR(50),
    email VARCHAR(100)
);
```

#### 3. **Rows** = Individual Files in Drawer
```sql
INSERT INTO users VALUES (1, 'john_doe', 'john@example.com');
```

#### 4. **Users & Permissions** = Who Can Access Which Drawers
```sql
CREATE USER 'wordpress_user'@'%' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'%';
```

### MariaDB Container Setup

**Key Requirements:**
1. Must create a database for WordPress
2. Must create a database user (NOT root!)
3. Data must persist using volumes
4. Must be accessible only from WordPress container

```dockerfile
FROM alpine:3.19

RUN apk update && apk add mariadb mariadb-client

# Copy initialization script
COPY conf/init.sql /docker-entrypoint-initdb.d/
COPY tools/init-db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init-db.sh

EXPOSE 3306

CMD ["/usr/local/bin/init-db.sh"]
```

### Database Initialization Script

```bash
#!/bin/sh

# Initialize MariaDB data directory (like formatting a hard drive)
mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Start MariaDB temporarily to run setup commands
mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

-- Delete anonymous users (security!)
DELETE FROM mysql.user WHERE User='';

-- Create WordPress database (the filing cabinet)
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

-- Create WordPress user (the person with access)
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';

-- Give permissions (access to specific drawers)
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

FLUSH PRIVILEGES;
EOF

# Start MariaDB for real (keep it running)
exec mysqld --user=mysql
```

### Volume for Data Persistence

```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      device: /home/yourusername/data/mariadb
      o: bind
```

**Critical**: This ensures your database survives container restarts!

---

## 📝 WordPress + PHP-FPM

### What is WordPress?

**Analogy**: WordPress is like a **pre-furnished office building** - it comes with everything you need to start working (or blogging) immediately.

**Technical**: WordPress is a Content Management System (CMS) written in PHP.

### What is PHP-FPM?

**Analogy**: PHP-FPM is like a **team of workers** who execute PHP code:
- **PHP** = The programming language (like English)
- **FPM** = FastCGI Process Manager (the team manager)
- **FastCGI** = Communication protocol between NGINX and PHP

### The WordPress Flow

```
1. User visits yourusername.42.fr
2. NGINX receives HTTPS request
3. NGINX says "Hey PHP-FPM, process this .php file!"
4. PHP-FPM executes WordPress code
5. WordPress queries MariaDB for data
6. MariaDB returns data
7. WordPress generates HTML page
8. PHP-FPM sends HTML to NGINX
9. NGINX sends HTML to user's browser
```

### WordPress Configuration (wp-config.php)

```php
<?php
// Database connection (like phone number to call the database)
define('DB_NAME', getenv('DB_NAME'));
define('DB_USER', getenv('DB_USER'));
define('DB_PASSWORD', getenv('DB_PASS'));
define('DB_HOST', 'mariadb:3306');  // Container name!

// Security keys (like passwords for cookie encryption)
define('AUTH_KEY',         'generate-random-string');
define('SECURE_AUTH_KEY',  'generate-random-string');
define('LOGGED_IN_KEY',    'generate-random-string');
define('NONCE_KEY',        'generate-random-string');

// WordPress debugging
define('WP_DEBUG', false);

// That's all, stop editing!
if (!defined('ABSPATH'))
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
```

### WordPress CLI (WP-CLI)

**Analogy**: WP-CLI is like a **remote control** for WordPress - instead of clicking buttons in browser, you type commands.

```bash
# Download WordPress
wp core download --allow-root

# Install WordPress
wp core install \
  --url="yourusername.42.fr" \
  --title="My Inception Site" \
  --admin_user="admin" \
  --admin_password="securepass" \
  --admin_email="admin@student.42.fr" \
  --allow-root

# Create additional user (project requirement!)
wp user create editor editor@student.42.fr \
  --role=editor \
  --user_pass="editorpass" \
  --allow-root
```

### WordPress Dockerfile

```dockerfile
FROM alpine:3.19

# Install PHP and extensions
RUN apk update && apk add \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    wget

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php81/php-fpm.d/www.conf

WORKDIR /var/www/html

COPY tools/init-wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-wordpress.sh

EXPOSE 9000

CMD ["/usr/local/bin/init-wordpress.sh"]
```

---

## 🔒 Networking & Security

### Docker Networks Explained

**Analogy**: Docker networks are like **private walkie-talkie channels** - only containers on the same channel can talk to each other.

```yaml
networks:
  inception-net:
    driver: bridge  # Creates a virtual network switch
```

**Bridge Network**: Like a local office network - containers can talk by name:
- `ping mariadb` works from WordPress container
- `curl http://wordpress:9000` works from NGINX

### Network Isolation

```
[Internet] 
    ↓
[Port 443] → [NGINX Container]
                  ↓
          [inception-net network]
                  ↓
         [WordPress Container] ←→ [MariaDB Container]
```

**Important**: Only NGINX port 443 is exposed to outside world!

### Environment Variables Security

**❌ NEVER DO THIS:**
```yaml
environment:
  MYSQL_ROOT_PASSWORD: supersecretpassword  # Visible in git!
```

**✅ DO THIS:**
```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASS}  # From .env file
```

Create `.env` file (and add to `.gitignore`!):
```bash
DB_ROOT_PASS=supersecretpassword
DB_NAME=wordpress_db
DB_USER=wp_user
DB_PASS=wp_password
DOMAIN_NAME=yourusername.42.fr
```

### SSL/TLS Security

**Analogy**: SSL/TLS is like sending a letter in a **locked box** that only the recipient can open.

```nginx
# Only allow secure protocols
ssl_protocols TLSv1.2 TLSv1.3;

# Use strong encryption ciphers
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';

# Prefer server ciphers
ssl_prefer_server_ciphers on;
```

---

## 🛠️ System Administration

### Linux Basics for Inception

#### 1. **Alpine vs Debian**

| Aspect | Alpine | Debian |
|--------|--------|--------|
| **Size** | Tiny (5MB) | Larger (124MB) |
| **Package Manager** | `apk` | `apt` |
| **Init System** | OpenRC | systemd |
| **Use Case** | Containers | Traditional servers |

**For Inception**: Use Alpine for smaller image sizes!

```dockerfile
# Alpine
FROM alpine:3.19
RUN apk update && apk add nginx

# Debian
FROM debian:bullseye
RUN apt-get update && apt-get install -y nginx
```

#### 2. **File Permissions**

**Analogy**: Permissions are like **key cards** to rooms - read, write, execute.

```bash
# Give execute permission to script
chmod +x init.sh

# Change ownership to www-data user
chown -R www-data:www-data /var/www/html

# Permissions breakdown:
# rwxr-xr-x = Owner can read/write/execute, others can read/execute
```

#### 3. **Process Management**

```bash
# Check if service is running
ps aux | grep nginx

# Kill process gracefully
kill -SIGTERM <PID>

# Kill process forcefully (last resort!)
kill -9 <PID>
```

#### 4. **Logs & Debugging**

```bash
# View container logs
docker logs nginx

# Follow logs in real-time
docker logs -f wordpress

# Enter running container
docker exec -it mariadb sh

# Check if port is listening
netstat -tulpn | grep 443
```

### Shell Scripting for Initialization

**Purpose**: Automate container setup on startup.

```bash
#!/bin/sh
# Shebang - tells OS to use /bin/sh to execute this script

# Exit if any command fails (safety net!)
set -e

# Wait for MariaDB to be ready (the RIGHT way)
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"mariadb" --silent; do
    sleep 1
done

echo "MariaDB is ready! Installing WordPress..."

# Download and configure WordPress
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost="mariadb:3306" \
        --allow-root
fi

# Start PHP-FPM in foreground (PID 1!)
exec php-fpm81 -F
```

**Key Concepts:**
- `set -e`: Stop script if any command fails
- `exec`: Replace current process (becomes PID 1)
- `-F`: Run in foreground (important for Docker!)

---

## 📁 Project Structure

### Recommended Directory Layout

```
inception/
├── Makefile                 # Build and management commands
├── .env                     # Environment variables (DON'T COMMIT!)
├── .gitignore              # Ignore .env and data folders
│
├── srcs/
│   ├── docker-compose.yml  # Main orchestration file
│   │
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── nginx.conf
│       │   └── tools/
│       │       └── setup.sh
│       │
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── www.conf
│       │   └── tools/
│       │       └── init-wordpress.sh
│       │
│       └── mariadb/
│           ├── Dockerfile
│           ├── conf/
│           │   └── my.cnf
│           └── tools/
│               └── init-db.sh
│
└── data/                   # Persistent data (created by volumes)
    ├── wordpress/
    └── mariadb/
```

### Makefile - The Command Center

```makefile
# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

# Default target
all: up

# Build images
build:
	mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	docker-compose -f $(COMPOSE_FILE) build

# Start containers
up: build
	docker-compose -f $(COMPOSE_FILE) up -d

# Stop containers
down:
	docker-compose -f $(COMPOSE_FILE) down

# Stop and remove everything
clean: down
	docker system prune -af
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

# Remove data (DANGEROUS!)
fclean: clean
	sudo rm -rf $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb

# Rebuild everything
re: fclean all

# Show status
status:
	docker-compose -f $(COMPOSE_FILE) ps

# View logs
logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

.PHONY: all build up down clean fclean re status logs
```

---

## ⚠️ Common Pitfalls

### 1. **Container Exits Immediately**

**Problem**: Container starts then immediately stops.

**Cause**: Main process exits or runs in background.

```dockerfile
# ❌ WRONG - nginx runs as daemon (background)
CMD ["nginx"]

# ✅ CORRECT - nginx runs in foreground
CMD ["nginx", "-g", "daemon off;"]
```

### 2. **WordPress Can't Connect to Database**

**Problem**: `Error establishing database connection`

**Debugging Steps:**
```bash
# 1. Check if MariaDB is running
docker ps

# 2. Check MariaDB logs
docker logs mariadb

# 3. Try connecting manually from WordPress container
docker exec -it wordpress sh
ping mariadb              # Should resolve
mysql -h mariadb -u wp_user -p  # Try connecting

# 4. Verify environment variables
docker exec wordpress env | grep DB_
```

### 3. **Permission Denied Errors**

**Problem**: Can't write to `/var/www/html`

**Solution**:
```bash
# In WordPress Dockerfile
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html
```

### 4. **Port Already in Use**

**Problem**: `Error: bind: address already in use`

**Solution**:
```bash
# Find what's using port 443
sudo lsof -i :443

# Kill the process
sudo kill -9 <PID>

# Or use different port temporarily
ports:
  - "8443:443"
```

### 5. **Volume Data Not Persisting**

**Problem**: Data disappears after `docker-compose down`

**Check**:
```yaml
# Make sure volumes are defined at TOP level
volumes:
  wordpress_data:
  db_data:

# And mapped in services
services:
  wordpress:
    volumes:
      - wordpress_data:/var/www/html
```

### 6. **SSL Certificate Errors**

**Problem**: Browser shows security warning

**This is NORMAL** for self-signed certificates! Just click "Advanced" → "Proceed to site".

### 7. **Services Can't Find Each Other**

**Problem**: `wordpress` can't ping `mariadb`

**Solution**: Ensure all services are on same network:
```yaml
services:
  wordpress:
    networks:
      - inception-net
  mariadb:
    networks:
      - inception-net

networks:
  inception-net:
```

---

## 🎯 42 Project Specific Requirements

### Mandatory Rules Checklist

- [ ] Use **Alpine or Debian** only
- [ ] Each service in its **own container**
- [ ] **Custom Dockerfiles** (no ready-made images from DockerHub)
- [ ] NGINX with **TLSv1.2 or TLSv1.3** only
- [ ] WordPress with **php-fpm**
- [ ] MariaDB database
- [ ] **Two volumes**: one for WordPress, one for MariaDB
- [ ] **Docker network** connecting all containers
- [ ] Containers **restart on crash**
- [ ] Domain: `login.42.fr` (your username)
- [ ] WordPress must have **at least 2 users** (1 admin, 1 regular)

### Environment Variables (.env)

```bash
# Domain
DOMAIN_NAME=yourusername.42.fr

# MariaDB
DB_NAME=wordpress_db
DB_USER=wp_user
DB_PASS=secure_password_123
DB_ROOT_PASS=root_password_456

# WordPress Admin
WP_ADMIN_USER=admin
WP_ADMIN_PASS=admin_pass_789
WP_ADMIN_EMAIL=admin@student.42.fr

# WordPress User
WP_USER=editor
WP_USER_PASS=editor_pass_012
WP_USER_EMAIL=editor@student.42.fr
```

### Hosts File Configuration

Add to `/etc/hosts`:
```bash
127.0.0.1   yourusername.42.fr
```

---

## 🚀 Quick Start Commands

```bash
# 1. Clone/create your project
cd ~
mkdir inception && cd inception

# 2. Create structure
mkdir -p srcs/requirements/{nginx,wordpress,mariadb}/{conf,tools}
mkdir -p data/{wordpress,mariadb}

# 3. Create .env file
nano .env  # Add your environment variables

# 4. Build and start
make all

# 5. Check status
make status
docker ps

# 6. View logs
make logs

# 7. Access your site
# Open browser: https://yourusername.42.fr
# (Accept security warning for self-signed cert)

# 8. Stop everything
make down

# 9. Clean everything
make fclean
```

---

## 📚 Useful Commands Reference

### Docker Commands
```bash
# Build image
docker build -t image_name .

# Run container
docker run -d --name container_name image_name

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop container
docker stop container_name

# Remove container
docker rm container_name

# View logs
docker logs container_name
docker logs -f container_name  # Follow logs

# Execute command in running container
docker exec -it container_name sh

# Inspect container
docker inspect container_name

# Remove all stopped containers
docker container prune

# Remove all unused images
docker image prune -a
```

### Docker Compose Commands
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild services
docker-compose build --no-cache

# Restart specific service
docker-compose restart nginx

# View service status
docker-compose ps
```

### Debugging Commands
```bash
# Check if port is open
netstat -tulpn | grep 443

# Test database connection
mysql -h 127.0.0.1 -P 3306 -u wp_user -p

# Check DNS resolution inside container
docker exec wordpress ping mariadb

# View container resource usage
docker stats

# Check volume contents
docker volume inspect volume_name
```

---

## 💡 Pro Tips from a DevOps Engineer

1. **Always Use Logs**: When something breaks, check logs first
   ```bash
   docker logs <container_name>
   ```

2. **Test Incrementally**: Build one service at a time, test, then add next

3. **Use .dockerignore**: Prevent unnecessary files in image
   ```
   .git
   .env
   *.md
   data/
   ```

4. **Health Checks**: Add health checks to know when service is REALLY ready
   ```yaml
   healthcheck:
     test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
     interval: 10s
     timeout: 5s
     retries: 5
   ```

5. **Keep Images Small**: 
   - Use Alpine
   - Combine RUN commands
   - Clean up after installs
   ```dockerfile
   RUN apk add --no-cache nginx && \
       rm -rf /var/cache/apk/*
   ```

6. **Document Everything**: Future you will thank present you

7. **Use Version Control**: Commit often, commit small changes

8. **Backup Your .env**: Store securely (not in git!)

9. **Test Certificate First**: Generate and test SSL cert before full deployment

10. **Read Error Messages**: They usually tell you exactly what's wrong!

---

## 🎓 Learning Resources

### Official Documentation
- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [NGINX Docs](https://nginx.org/en/docs/)
- [MariaDB Docs](https://mariadb.org/documentation/)
- [WordPress Codex](https://wordpress.org/documentation/)

### Testing Your Knowledge
Try to answer these without looking:
1. What's the difference between CMD and ENTRYPOINT?
2. Why must processes run in foreground in Docker?
3. What happens to data without volumes?
4. How do containers on same network find each other?
5. What does `depends_on` actually wait for?

### Next Steps After Inception
1. Learn Kubernetes (container orchestration at scale)
2. Study CI/CD pipelines
3. Explore monitoring tools (Prometheus, Grafana)
4. Learn Infrastructure as Code (Terraform)
5. Deep dive into security (container scanning, secrets management)

---

## 🎉 Final Words

Remember: **Everyone struggles with Docker at first**. It's normal to:
- Have containers exit immediately
- Spend hours debugging networking
- Forget `daemon off` in nginx
- Wonder why data disappeared

The key is **patience and systematic debugging**:
1. Check logs
2. Verify environment variables
3. Test connectivity between containers
4. Verify file permissions
5. Read error messages carefully

**You got this!** 🚀

When you finish Inception, you'll understand more about DevOps than many junior engineers. This project is tough but incredibly valuable.

Good luck, and may your containers always stay running! 🐳

---

## 🎤 DEFENSE/EVALUATION QUESTIONS & ANSWERS

This section contains **all possible questions** you might be asked during your Inception defense, with clear, simple answers you can easily remember and explain.

---

### 📚 GENERAL UNDERSTANDING

#### Q1: **What is Docker?**
**Simple Answer**: Docker is like a shipping container for software. It packages your application with everything it needs (code, libraries, dependencies) so it runs the same everywhere - on your laptop, your friend's computer, or a server.

**For Evaluator**: "Instead of saying 'it works on my machine', Docker ensures it works on ANY machine because everything is packaged together."

---

#### Q2: **What's the difference between a Virtual Machine and a Container?**

**Analogy Answer**: 
- **VM** = Buying an entire apartment building (includes everything: walls, plumbing, electricity)
- **Container** = Renting a room in an apartment (shares building utilities, lighter & faster)

**Technical Answer**:
- **VM**: Runs a full operating system, includes kernel, heavy (GBs), slow to start
- **Container**: Shares host OS kernel, only includes application & dependencies, light (MBs), starts in seconds

**Visual Comparison**:
```
VM:                          Container:
[App A] [App B]             [App A] [App B] [App C]
[OS]    [OS]                [Docker Engine]
[Hypervisor]                [Host OS]
[Host OS]                   [Hardware]
[Hardware]
```

---

#### Q3: **What is the difference between an Image and a Container?**

**Simple Answer**: 
- **Image** = Recipe/Blueprint (frozen, can't change)
- **Container** = The actual cake you baked from that recipe (running, active)

**Example**: 
```bash
docker build -t my-app .    # Creates image (recipe)
docker run my-app           # Creates container (the running cake)
```

You can make 10 containers from 1 image, just like baking 10 cakes from 1 recipe.

---

#### Q4: **What is Docker Compose?**

**Simple Answer**: Docker Compose is like a restaurant manager who coordinates the entire kitchen. Instead of manually starting the chef (WordPress), the sous-chef (NGINX), and the prep cook (MariaDB) one by one, the manager starts everyone with one command.

**Technical**: Docker Compose is a tool for defining and running multi-container applications using a YAML configuration file.

**One Command**:
```bash
docker-compose up    # Starts ALL services
# vs
docker r
un nginx
docker run wordpress
docker run mariadb   # Manual, error-prone
```

---

### 🐳 DOCKER-SPECIFIC QUESTIONS

#### Q5: **What is a Dockerfile?**

**Simple Answer**: A Dockerfile is a **recipe book** with step-by-step instructions to build your image. Each line is a step: "Get Alpine Linux", "Install NGINX", "Copy config file", "Start NGINX".

**Example**:
```dockerfile
FROM alpine:3.19           # Step 1: Get base ingredient
RUN apk add nginx          # Step 2: Install tool
COPY nginx.conf /etc/      # Step 3: Add your config
CMD ["nginx", "-g", "daemon off;"]  # Step 4: Start it
```

---

#### Q6: **What's the difference between CMD and ENTRYPOINT?**

**Simple Answer**:
- **CMD** = Default suggestion (can be overridden)
- **ENTRYPOINT** = Mandatory rule (can't be easily overridden)

**Example**:
```dockerfile
# With CMD
CMD ["nginx", "-g", "daemon off;"]
# User can run: docker run my-image /bin/sh  (overrides CMD)

# With ENTRYPOINT
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
# User can run: docker run my-image -v  (only changes CMD part)
```

**When to use**:
- **CMD**: When you want flexibility
- **ENTRYPOINT**: When you want to ensure a specific program always runs

---

#### Q7: **What's the difference between COPY and ADD?**

**Simple Answer**:
- **COPY**: Just copies files (simple, predictable)
- **ADD**: Copies + has magic features (can extract tar files, download URLs)

**Best Practice**: Always use COPY unless you specifically need ADD's features.

```dockerfile
COPY nginx.conf /etc/nginx/   # ✅ Clear and simple
ADD nginx.conf /etc/nginx/    # ⚠️ Works but unnecessary
```

---

#### Q8: **What does "daemon off" mean in nginx?**

**Critical Concept**: 
```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

**Simple Answer**: By default, NGINX runs in the **background** (as a daemon). But Docker needs the main process to run in the **foreground**, otherwise Docker thinks the container is done and stops it.

**Analogy**: 
- **Daemon mode** = Chef goes to work in the back room (Docker can't see him, thinks restaurant closed)
- **Foreground mode** = Chef works at the front counter (Docker sees he's working, keeps restaurant open)

**What happens without it**:
```bash
docker run nginx        # Starts, immediately exits ❌
docker ps              # No running containers!
```

---

#### Q9: **What is the PID 1 problem?**

**Simple Answer**: In Docker, the first process that starts becomes PID 1 (Process ID 1), which is the "boss" of the container. If PID 1 exits, the entire container shuts down.

**Problem**: Some programs don't handle being PID 1 well - they can't clean up zombie processes properly.

**Solution**: Use `exec` to replace the shell with your actual program:
```bash
#!/bin/sh
# Bad - shell becomes PID 1
nginx -g "daemon off;"

# Good - nginx becomes PID 1
exec nginx -g "daemon off;"
```

**Analogy**: PID 1 is the building manager. If the manager quits, the building closes. You want your main service (nginx) to be the manager, not a shell script.

---

#### Q10: **Why can't we use ready-made Docker images from DockerHub?**

**42 Rule**: You must build your own Dockerfiles from scratch using only Alpine or Debian base images.

**Reason**: 
1. **Learning**: You need to understand how services are configured
2. **Security**: You know exactly what's in your image
3. **Customization**: You control every aspect

**Allowed**:
```dockerfile
FROM alpine:3.19          # ✅ Base OS image
FROM debian:bullseye      # ✅ Base OS image
```

**Not Allowed**:
```dockerfile
FROM nginx:latest         # ❌ Pre-built service image
FROM wordpress:latest     # ❌ Pre-built service image
```

---

### 🌐 NGINX QUESTIONS

#### Q11: **What is NGINX?**

**Simple Answer**: NGINX is a **web server** that acts as the front door to your website. It's like a receptionist who:
1. Greets visitors (receives requests)
2. Checks their credentials (SSL/TLS)
3. Directs them to the right place (reverse proxy to WordPress)

**Technical**: NGINX is a high-performance web server and reverse proxy.

---

#### Q12: **Why do we need NGINX if we already have WordPress?**

**Great Question!** WordPress can't handle HTTPS directly. Here's why we need NGINX:

1. **SSL/TLS Termination**: NGINX handles HTTPS encryption
2. **Reverse Proxy**: Forwards requests to WordPress (which only speaks PHP)
3. **Performance**: NGINX serves static files (images, CSS) faster
4. **Security**: Acts as a shield in front of WordPress

**Flow**:
```
Browser (HTTPS) → NGINX (handles SSL) → WordPress (PHP-FPM) → MariaDB
```

---

#### Q13: **What is a reverse proxy?**

**Simple Analogy**: A reverse proxy is like a **hotel concierge**:

1. Guest arrives at front desk (browser sends request to NGINX)
2. Concierge receives request (NGINX on port 443)
3. Concierge directs guest to room 201 (WordPress container)
4. Room service prepares order (WordPress generates page)
5. Concierge delivers to guest (NGINX sends response to browser)

**Why "Reverse"?**: 
- **Forward proxy**: Hides the client (like a VPN - protects YOU)
- **Reverse proxy**: Hides the server (protects YOUR SERVER)

---

#### Q14: **What is TLS/SSL? Why do we use it?**

**Simple Answer**: TLS/SSL is **encryption** for web traffic. It's like putting your letter in a locked box that only the recipient can open.

**Without HTTPS (HTTP)**:
```
Browser → "password123" → Server
        ↑ Anyone can read this! 😱
```

**With HTTPS (HTTP + TLS)**:
```
Browser → "kj#$%^&*Encrypted*&^%$#jk" → Server
        ↑ Only server can decrypt! ✅
```

**Why TLSv1.2 or TLSv1.3?**: Older versions (TLSv1.0, TLSv1.1) have security vulnerabilities.

---

#### Q15: **What is a self-signed certificate? Why does the browser complain?**

**Simple Answer**: 
- **Normal Certificate**: Issued by a trusted authority (like a government ID)
- **Self-signed Certificate**: You made it yourself (like a homemade ID card)

**Browser Warning**: "I don't recognize this ID, are you sure you trust it?"

**For School Projects**: Self-signed certificates are fine! In production, you'd use Let's Encrypt or buy a certificate.

**How to Generate**:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx.key -out nginx.crt \
  -subj "/CN=yourusername.42.fr"
```

---

#### Q16: **What is FastCGI?**

**Simple Answer**: FastCGI is a **communication protocol** between NGINX and PHP. It's like a phone line between the receptionist (NGINX) and the chef (PHP-FPM).

**Why not just run PHP files directly?**: NGINX doesn't understand PHP! It needs PHP-FPM to execute PHP code.

**Configuration**:
```nginx
location ~ \.php$ {
    fastcgi_pass wordpress:9000;  # Call PHP-FPM at port 9000
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

**Flow**:
```
1. NGINX receives index.php request
2. NGINX says: "Hey PHP-FPM, execute this file!"
3. PHP-FPM runs WordPress code
4. PHP-FPM returns HTML
5. NGINX sends HTML to browser
```

---

### 🗄️ MARIADB QUESTIONS

#### Q17: **What is MariaDB? Why not MySQL?**

**Simple Answer**: MariaDB is a **fork** of MySQL (like a twin brother). They're almost identical, but MariaDB is:
- Fully open-source
- Slightly faster
- Compatible with WordPress

**Analogy**: If MySQL is Coca-Cola, MariaDB is Pepsi - very similar, slightly different recipe.

---

#### Q18: **What is a database? What is a table?**

**Simple Analogy**:
- **Database** = Filing cabinet 🗄️
- **Table** = Individual drawer 📁
- **Row** = Individual file in drawer 📄
- **Column** = Information fields (name, email, date)

**WordPress Example**:
```
Database: wordpress_db
├── Table: wp_users
│   ├── Row 1: (id=1, username=admin, email=admin@42.fr)
│   └── Row 2: (id=2, username=editor, email=editor@42.fr)
│
└── Table: wp_posts
    ├── Row 1: (id=1, title="Hello World", content="...")
    └── Row 2: (id=2, title="My First Post", content="...")
```

---

#### Q19: **Why can't we use the root user for WordPress?**

**Security Best Practice**: Root user has **ALL PRIVILEGES** on **ALL DATABASES** - like giving someone master keys to every building in the city.

**Better Approach**: Create a specific user with access to ONLY the WordPress database:

```sql
-- ❌ BAD: WordPress uses root
-- If WordPress is hacked, attacker has access to EVERYTHING

-- ✅ GOOD: WordPress uses limited user
CREATE USER 'wp_user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'%';
-- wp_user can only access wordpress_db, nothing else
```

**Analogy**: Don't give the janitor master keys to the bank vault - give them keys only to rooms they need to clean.

---

#### Q20: **What does '@'%' mean in CREATE USER?**

**Simple Explanation**:
```sql
CREATE USER 'wp_user'@'%' IDENTIFIED BY 'password';
                      ↑
                      This part!
```

**Means**: User can connect from **any host**

**Options**:
- `'wp_user'@'localhost'` - Can only connect from same machine
- `'wp_user'@'%'` - Can connect from anywhere (% is wildcard)
- `'wp_user'@'wordpress'` - Can only connect from container named 'wordpress'

**For Inception**: We use `'%'` because WordPress container is on a different network address.

---

#### Q21: **What is mysql_install_db? Why do we need it?**

**Simple Answer**: `mysql_install_db` creates the basic folder structure and system tables that MariaDB needs to function. It's like **formatting a hard drive** before you can use it.

**Without it**: MariaDB can't start because it doesn't have the necessary system databases.

```bash
# Initialize database directory
mysql_install_db --user=mysql --datadir=/var/lib/mysql
```

**What it creates**:
```
/var/lib/mysql/
├── mysql/          # System database
├── performance_schema/
└── test/
```

---

### 📝 WORDPRESS QUESTIONS

#### Q22: **What is WordPress?**

**Simple Answer**: WordPress is a **Content Management System (CMS)** - a pre-built website that lets you create and manage content without writing HTML/CSS/JavaScript yourself.

**Analogy**: WordPress is like a **pre-furnished office**. Instead of building everything from scratch, you move in and start working immediately.

**Popular**: ~43% of all websites use WordPress!

---

#### Q23: **What is PHP-FPM?**

**Full Name**: PHP FastCGI Process Manager

**Simple Answer**: PHP-FPM is a **team of workers** who execute PHP code:
- **PHP** = The programming language WordPress is written in
- **FPM** = Manager who coordinates multiple PHP workers
- **FastCGI** = Communication protocol with NGINX

**Why FPM?**: 
- Handles multiple requests simultaneously (like having multiple chefs)
- More efficient than running PHP as a module
- Can restart failed workers automatically

**Configuration**:
```bash
# Make PHP-FPM listen on port 9000 (so NGINX can talk to it)
listen = 9000
```

---

#### Q24: **Why does WordPress need MariaDB?**

**Simple Answer**: WordPress needs to **store data** somewhere:
- User accounts (username, password, email)
- Blog posts (title, content, author, date)
- Comments, settings, plugins, themes, etc.

**Without Database**: Every time you restart WordPress, you'd lose everything! 💀

**With Database**: Data persists forever (as long as volume exists) ✅

---

#### Q25: **What is WP-CLI?**

**Full Name**: WordPress Command Line Interface

**Simple Answer**: WP-CLI is a **remote control** for WordPress. Instead of clicking buttons in a web browser, you type commands in terminal.

**Why Use It?**: 
- Automate WordPress installation
- Create users without GUI
- Perfect for Docker containers (no browser needed!)

**Example Commands**:
```bash
# Download WordPress
wp core download --allow-root

# Install WordPress
wp core install \
  --url="login.42.fr" \
  --title="My Site" \
  --admin_user="admin" \
  --admin_password="pass" \
  --admin_email="admin@42.fr" \
  --allow-root

# Create user
wp user create editor editor@42.fr \
  --role=editor \
  --user_pass="pass" \
  --allow-root
```

---

#### Q26: **Why do we need at least 2 WordPress users?**

**42 Requirement**: To demonstrate you understand user management.

**Roles**:
1. **Administrator** (admin user):
   - Full control over site
   - Can install plugins, change themes, manage users
   - Like the CEO of a company

2. **Editor** (regular user):
   - Can publish and edit posts
   - Can't change site settings or install plugins
   - Like a content writer

**Other Roles**: Author, Contributor, Subscriber (less permissions)

---

### 🔗 NETWORKING QUESTIONS

#### Q27: **What is a Docker network?**

**Simple Answer**: A Docker network is like a **private walkie-talkie channel**. Only containers on the same channel can talk to each other.

**Benefits**:
- Containers can communicate by name (no need for IP addresses)
- Isolated from outside world
- Secure

**Example**:
```yaml
networks:
  inception-net:
    driver: bridge
```

**Result**: 
- WordPress can ping MariaDB: `ping mariadb` ✅
- WordPress can connect to MariaDB: `mysql -h mariadb` ✅

---

#### Q28: **What is a bridge network?**

**Simple Answer**: A bridge network is like a **virtual switch** that connects containers together.

**Analogy**: It's like an office network where all computers are connected to the same switch - they can all talk to each other.

**Types**:
- **Bridge** (default): Containers on same host can communicate
- **Host**: Container uses host's network directly
- **None**: No networking

**For Inception**: We use bridge network.

---

#### Q29: **How do containers find each other by name?**

**Magic**: Docker has a built-in **DNS server**!

**Example**:
```yaml
services:
  wordpress:
    container_name: wordpress
  mariadb:
    container_name: mariadb
```

**Inside WordPress container**:
```bash
ping mariadb          # Works! Docker DNS resolves to MariaDB's IP
mysql -h mariadb      # Works! Can connect by name
```

**Docker DNS** acts like a phone book:
```
mariadb → 172.18.0.2
wordpress → 172.18.0.3
nginx → 172.18.0.4
```

---

#### Q30: **Why do we only expose port 443?**

**Security Principle**: **Minimize attack surface** - only expose what's absolutely necessary.

**Setup**:
```yaml
nginx:
  ports:
    - "443:443"    # Only NGINX port is exposed to outside
wordpress:
  # No ports exposed!
mariadb:
  # No ports exposed!
```

**Result**:
```
[Internet] 
    ↓
  Port 443
    ↓
[NGINX] ← Only entry point!
    ↓
[WordPress] ← Hidden from internet
    ↓
[MariaDB] ← Hidden from internet
```

**Analogy**: NGINX is the **front door** to a building. WordPress and MariaDB are rooms inside - you can't access them from the street.

---

### 💾 VOLUMES QUESTIONS

#### Q31: **What are Docker volumes?**

**Simple Answer**: Volumes are like **external hard drives** for containers. When you delete a container, the volume keeps your data safe.

**Without Volumes**:
```bash
docker run mariadb    # Create database with posts
docker rm mariadb     # Delete container
docker run mariadb    # All posts are GONE! 💀
```

**With Volumes**:
```bash
docker run -v db_data:/var/lib/mysql mariadb  # Data stored in volume
docker rm mariadb                              # Delete container
docker run -v db_data:/var/lib/mysql mariadb  # Posts are STILL THERE! ✅
```

---

#### Q32: **Where is volume data actually stored?**

**Two Types**:

**1. Named Volume** (Docker manages location):
```yaml
volumes:
  wordpress_data:    # Docker stores in /var/lib/docker/volumes/
```

**2. Bind Mount** (You choose location):
```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      device: /home/username/data/wordpress  # Your chosen path
      o: bind
```

**For 42**: You typically use **bind mounts** to store data in your home directory.

---

#### Q33: **Why do we need 2 volumes?**

**42 Requirement**: One volume for WordPress files, one for database files.

**Reason**: They store different types of data:

**1. WordPress Volume** (`/var/www/html`):
- WordPress core files
- Themes and plugins
- Uploaded images/media
- wp-config.php

**2. MariaDB Volume** (`/var/lib/mysql`):
- Database files
- User data
- Posts content
- Settings

**Analogy**: You need separate closets for clothes and shoes - different storage for different purposes.

---

### 🛠️ TROUBLESHOOTING QUESTIONS

#### Q34: **Container keeps exiting immediately. How do you debug?**

**Systematic Approach**:

**1. Check logs first**:
```bash
docker logs container_name
docker-compose logs container_name
```

**2. Common causes**:
- ❌ Process runs in background (needs `daemon off`)
- ❌ Process crashes (check logs!)
- ❌ Missing configuration file
- ❌ Wrong permissions

**3. Test manually**:
```bash
# Start container with shell instead of default CMD
docker run -it --entrypoint /bin/sh my-image

# Now manually run your service and see errors
nginx -g "daemon off;"
```

---

#### Q35: **WordPress says "Error establishing database connection". What do you check?**

**Debugging Checklist**:

**1. Is MariaDB running?**
```bash
docker ps | grep mariadb
```

**2. Can WordPress reach MariaDB?**
```bash
docker exec -it wordpress sh
ping mariadb              # Should work
```

**3. Are credentials correct?**
```bash
docker exec wordpress env | grep DB_
# Check: DB_NAME, DB_USER, DB_PASS match MariaDB
```

**4. Can you connect manually?**
```bash
docker exec -it wordpress sh
mysql -h mariadb -u wp_user -p
# Enter password, see if connection works
```

**5. Is MariaDB ready?**
```bash
docker logs mariadb
# Look for: "ready for connections"
```

---

#### Q36: **How do you restart just one service?**

**With Docker Compose**:
```bash
# Restart single service
docker-compose restart nginx

# Rebuild and restart single service
docker-compose up -d --build nginx

# Stop single service
docker-compose stop nginx

# Start single service
docker-compose start nginx
```

**Without Compose**:
```bash
docker restart nginx
```

---

### 🎯 PROJECT-SPECIFIC QUESTIONS

#### Q37: **Why can't we use environment variables in the Dockerfile?**

**42 Rule**: Sensitive data must be in `.env` file, not hardcoded.

**Wrong**:
```dockerfile
ENV DB_PASSWORD=secretpass123  # Hardcoded = bad!
```

**Correct**:
```yaml
# docker-compose.yml
services:
  mariadb:
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASS}  # From .env file
```

**Why?**: 
- `.env` file is in `.gitignore` - secrets never committed
- Easy to change passwords without rebuilding images
- Different passwords for dev/production

---

#### Q38: **What is a Makefile? Why do we use it?**

**Simple Answer**: A Makefile is a **shortcut button collection**. Instead of typing long commands, you type short ones.

**Example**:
```makefile
# Without Makefile:
docker-compose -f srcs/docker-compose.yml up -d --build

# With Makefile:
make up
```

**Common Targets**:
```makefile
make all      # Build and start everything
make down     # Stop everything
make clean    # Remove containers and images
make fclean   # Remove everything including data
make re       # Rebuild from scratch
make logs     # View logs
```

**Analogy**: Makefile is like speed dial on your phone - instead of typing full number, press one button.

---

#### Q39: **Why do we need to modify /etc/hosts?**

**Problem**: Your domain `yourusername.42.fr` doesn't exist on the internet.

**Solution**: Tell your computer that `yourusername.42.fr` points to `localhost` (127.0.0.1).

**Add to /etc/hosts**:
```bash
127.0.0.1   yourusername.42.fr
```

**Now**:
```
Browser types: https://yourusername.42.fr
↓
Computer checks /etc/hosts
↓
"Ah, yourusername.42.fr = 127.0.0.1 (my own machine)"
↓
Connects to localhost port 443
↓
NGINX receives request!
```

**Edit File**:
```bash
sudo nano /etc/hosts
# Add line: 127.0.0.1   yourusername.42.fr
# Save and exit
```

---

#### Q40: **Explain the entire flow: Browser to Database and back**

**Complete Journey**:

```
1. User types: https://yourusername.42.fr
   ↓
2. Browser looks up IP in /etc/hosts → 127.0.0.1
   ↓
3. Browser connects to port 443 with HTTPS
   ↓
4. NGINX receives encrypted request
   ↓
5. NGINX decrypts SSL (terminates TLS)
   ↓
6. NGINX sees request is for index.php
   ↓
7. NGINX forwards to WordPress:9000 via FastCGI
   ↓
8. PHP-FPM receives request
   ↓
9. PHP-FPM executes WordPress code
   ↓
10. WordPress needs data: "SELECT * FROM wp_posts"
    ↓
11. WordPress connects to mariadb:3306
    ↓
12. MariaDB queries database and returns data
    ↓
13. WordPress generates HTML page with data
    ↓
14. PHP-FPM sends HTML back to NGINX
    ↓
15. NGINX encrypts HTML with SSL
    ↓
16. NGINX sends encrypted response to browser
    ↓
17. Browser decrypts and displays webpage!
```

**Summary**: Browser → NGINX (SSL) → WordPress (PHP) → MariaDB (Data) → WordPress → NGINX → Browser

---

### ⚙️ ADVANCED QUESTIONS

#### Q41: **What is the difference between docker-compose up and docker-compose start?**

**Key Difference**:

**`docker-compose up`**:
- Creates containers if they don't exist
- Starts containers
- Attaches to logs (unless -d flag)
- Rebuilds if Dockerfile changed (with --build)

**`docker-compose start`**:
- Only starts EXISTING containers
- Doesn't create new ones
- Doesn't rebuild

**Typical Usage**:
```bash
docker-compose up -d       # First time: create and start
docker-compose stop        # Stop containers
docker-compose start       # Restart existing containers
```

---

#### Q42: **What happens if MariaDB starts after WordPress?**

**Problem**: WordPress tries to connect to MariaDB before it's ready = **connection error**.

**Solution 1: depends_on** (partial solution):
```yaml
wordpress:
  depends_on:
    - mariadb    # WordPress starts after MariaDB
```

**⚠️ Limitation**: `depends_on` waits for container to START, not be READY!

**Solution 2: Wait Script** (complete solution):
```bash
#!/bin/sh
# In WordPress init script

# Wait until MariaDB is actually ready
while ! mysqladmin ping -h"mariadb" --silent; do
    echo "Waiting for MariaDB..."
    sleep 1
done

echo "MariaDB is ready! Starting WordPress..."
```

---

#### Q43: **What is .dockerignore? Why use it?**

**Simple Answer**: `.dockerignore` tells Docker what files to **ignore** when building images.

**Analogy**: Like `.gitignore` but for Docker.

**Why?**:
- Faster builds (less files to copy)
- Smaller images
- Avoid copying sensitive files

**Example .dockerignore**:
```
.git
.env
*.md
node_modules/
data/
.DS_Store
```

**Result**: When you `COPY . /app`, these files are skipped.

---

#### Q44: **Can you explain "restart: always" in docker-compose?**

**Simple Answer**: If container crashes or stops, Docker automatically restarts it.

```yaml
services:
  nginx:
    restart: always    # Auto-restart on crash
```

**Options**:
- `no`: Never restart (default)
- `always`: Always restart, even after system reboot
- `on-failure`: Only restart if container exits with error
- `unless-stopped`: Always restart unless manually stopped

**For 42**: Use `always` to ensure services stay running.

---

#### Q45: **What security measures are in your project?**

**Security Checklist**:

**1. TLS/SSL Encryption**:
```nginx
ssl_protocols TLSv1.2 TLSv1.3;    # Only secure versions
```

**2. No Hardcoded Credentials**:
```yaml
environment:
  MYSQL_PASSWORD: ${DB_PASS}    # From .env, not hardcoded
```

**3. Limited Database User**:
```sql
CREATE USER 'wp_user'@'%';    # Not root!
GRANT ALL ON wordpress_db.*;  # Only one database, not all
```

**4. Network Isolation**:
```
Only NGINX port exposed to internet
WordPress and MariaDB hidden behind network
```

**5. No Anonymous Database Users**:
```sql
DELETE FROM mysql.user WHERE User='';
```

**6. .gitignore for Secrets**:
```
.env        # Never commit passwords!
```

---

### 🎓 CONCEPTUAL QUESTIONS

#### Q46: **What did you learn from this project?**

**Good Answer Structure**:

1. **Docker Fundamentals**: "I learned how containerization works, the difference between images and containers, and how to write Dockerfiles."

2. **Orchestration**: "I understand how Docker Compose coordinates multiple services and how they communicate via networks."

3. **Web Stack**: "I learned how modern web applications work - NGINX as reverse proxy, WordPress for content, MariaDB for data storage."

4. **System Administration**: "I gained experience with Linux, shell scripting, process management, and troubleshooting."

5. **Security**: "I learned about SSL/TLS, network isolation, and keeping credentials secure."

6. **DevOps Mindset**: "I learned to think about infrastructure as code, automation with Makefiles, and systematic debugging."

---

#### Q47: **Why is this project called 'Inception'?**

**Fun Answer**: Like the movie "Inception" with dreams within dreams, this project has **containers within containers**:
- VM (virtual machine)
  - Docker (containerization platform)
    - Container (isolated environment)
      - Service (nginx/wordpress/mariadb)

**Layers of Abstraction**: Each layer provides isolation and abstraction from hardware.

---

#### Q48: **What would you do differently in production?**

**Great Question! Shows you understand real-world vs. school project**:

**1. SSL Certificates**:
- ❌ School: Self-signed certificates
- ✅ Production: Let's Encrypt or commercial certificate

**2. Secrets Management**:
- ❌ School: .env file
- ✅ Production: Docker Secrets, Vault, or cloud secrets manager

**3. High Availability**:
- ❌ School: Single instance
- ✅ Production: Multiple replicas, load balancer

**4. Monitoring**:
- ❌ School: Manual checking with `docker logs`
- ✅ Production: Prometheus, Grafana, ELK stack

**5. Orchestration**:
- ❌ School: Docker Compose
- ✅ Production: Kubernetes for large scale

**6. Backups**:
- ❌ School: Manual volume backups
- ✅ Production: Automated backups, replication

**7. Domain**:
- ❌ School: `localhost` with `/etc/hosts` hack
- ✅ Production: Real domain with proper DNS

---

### 🚨 BONUS QUESTIONS (If You Did Bonus Part)

#### Q49: **What bonus services did you add?**

**Common Bonus Services**:
- **Redis**: Caching layer for faster WordPress
- **FTP**: File transfer server
- **Adminer**: Database management UI
- **Static Website**: Custom service
- **Portainer**: Docker management UI

**For Each Bonus, Know**:
1. What it does
2. Why it's useful
3. How it connects to main services
4. How to demonstrate it works

---

#### Q50: **How do you demonstrate your project works?**

**Defense Checklist**:

**1. Show Architecture**:
```bash
docker-compose ps    # Show all running containers
docker network ls    # Show inception network
docker volume ls     # Show both volumes
```

**2. Access Website**:
- Open browser: `https://yourusername.42.fr`
- Accept self-signed certificate warning
- Show WordPress login
- Login with admin user
- Show dashboard

**3. Check Database Connection**:
```bash
docker exec -it mariadb sh
mysql -u wp_user -p
SHOW DATABASES;
USE wordpress_db;
SHOW TABLES;
SELECT * FROM wp_users;
```

**4. Show Configuration Files**:
- Show Dockerfiles
- Show docker-compose.yml
- Show NGINX config
- Show .env file (without passwords visible to camera!)

**5. Test Persistence**:
```bash
# Create a post in WordPress
make down          # Stop everything
make up            # Restart
# Show post is still there (data persisted!)
```

**6. Check Security**:
```bash
# Show only port 443 is exposed
docker ps
netstat -tuln | grep 443
```

---

## 💡 PRO TIPS FOR DEFENSE

### How to Ace Your Evaluation

**1. Be Confident but Honest**:
- If you don't know something, say "I'm not sure, but I think..."
- Don't make up answers
- Show you can debug and find answers

**2. Have Your Cheat Sheet Ready**:
- Print this Q&A section
- Keep Docker commands reference handy
- Have your architecture diagram ready

**3. Practice Common Commands**:
```bash
# Muscle memory for these:
docker ps
docker logs <container>
docker exec -it <container> sh
docker-compose logs
make status
```

**4. Explain with Analogies**:
- Use the analogies in this guide
- Draw diagrams if needed
- Make it relatable

**5. Show, Don't Just Tell**:
- Open files and show code
- Run commands and show output
- Navigate to website and demonstrate features

**6. Be Prepared for "What If" Questions**:
- "What if MariaDB crashes?"
  → "It will auto-restart because of `restart: always`"
- "What if volume is deleted?"
  → "All data is lost, that's why backups are important in production"
- "What if port 443 is already used?"
  → "I can change the port mapping in docker-compose.yml or stop the conflicting service"

**7. Know Your Logs**:
```bash
# Always check logs when something breaks
docker logs nginx 2>&1 | less       # Detailed view
docker-compose logs --tail=50       # Last 50 lines
docker-compose logs -f nginx        # Follow in real-time
```

---

## 📋 QUICK REFERENCE CARD

### Must-Know Commands

```bash
# Docker Basics
docker ps                          # List running containers
docker ps -a                       # List all containers
docker logs <container>            # View logs
docker exec -it <container> sh     # Enter container

# Docker Compose
docker-compose up -d               # Start all services
docker-compose down                # Stop all services
docker-compose ps                  # Service status
docker-compose logs -f             # Follow logs
docker-compose restart <service>   # Restart one service

# Makefile
make all         # Build and start
make down        # Stop
make clean       # Remove containers/images
make fclean      # Remove everything including data
make re          # Rebuild from scratch
make logs        # View logs

# Debugging
docker inspect <container>         # Detailed info
docker network inspect inception   # Network details
docker volume inspect <volume>     # Volume details
docker exec wordpress ping mariadb # Test connectivity
```

### Key Ports
- **443**: NGINX (HTTPS)
- **9000**: PHP-FPM (WordPress)
- **3306**: MariaDB

### Key Paths
- WordPress files: `/var/www/html`
- MariaDB data: `/var/lib/mysql`
- NGINX config: `/etc/nginx/nginx.conf`
- SSL certificates: `/etc/nginx/ssl/`

---

## 🎯 FINAL CHECKLIST BEFORE DEFENSE

- [ ] All containers running (`docker ps`)
- [ ] Can access website via browser
- [ ] Can login to WordPress
- [ ] At least 2 users exist
- [ ] Database has data
- [ ] Volumes are persistent (test with restart)
- [ ] Only port 443 exposed
- [ ] TLSv1.2/1.3 configured
- [ ] No passwords in git history
- [ ] .env file in .gitignore
- [ ] Makefile works (`make re`)
- [ ] Can explain every line in config files
- [ ] Know all Docker commands
- [ ] Practiced answering these questions
- [ ] Can draw architecture diagram
- [ ] Prepared for "why" questions

---


*Created with ❤️ by your DevOps mentor*
*Last updated: December 2024*

