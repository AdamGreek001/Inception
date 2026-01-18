# Inception

*This project has been created as part of the 42 curriculum by abogreek.*

## Description

**Inception** is a system administration project that uses Docker to set up a complete web infrastructure. The project creates a small infrastructure composed of different services running in isolated containers, all orchestrated using Docker Compose.

The infrastructure includes:
- **NGINX** - Web server with TLS/SSL encryption (only entry point via port 443)
- **WordPress** - Content Management System with PHP-FPM
- **MariaDB** - Relational database for WordPress data storage

### Architecture Overview

```
                    ┌─────────────────────────────────────────────────┐
                    │              Docker Host (VM)                    │
                    │                                                  │
     HTTPS:443      │   ┌─────────┐    ┌───────────┐    ┌──────────┐ │
    ──────────────►─┼──►│  NGINX  │───►│ WordPress │───►│ MariaDB  │ │
                    │   │ :443    │    │  :9000    │    │  :3306   │ │
                    │   └─────────┘    └───────────┘    └──────────┘ │
                    │        │               │               │        │
                    │   ┌────┴───────────────┴───────────────┴────┐  │
                    │   │           Docker Network (bridge)        │  │
                    │   └──────────────────────────────────────────┘  │
                    │                                                  │
                    │   ┌──────────────────┐  ┌───────────────────┐   │
                    │   │ Volume: wp_data  │  │ Volume: db_data   │   │
                    │   │ /data/wordpress  │  │ /data/mariadb     │   │
                    │   └──────────────────┘  └───────────────────┘   │
                    └─────────────────────────────────────────────────┘
```

---

## Comparisons

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|-------------------|
| **Isolation Level** | Full hardware virtualization | Process-level isolation using namespaces |
| **Resource Usage** | Heavy (includes full OS) | Lightweight (shares host kernel) |
| **Startup Time** | Minutes | Seconds |
| **Image Size** | Gigabytes | Megabytes |
| **Portability** | Limited (hypervisor-dependent) | Highly portable across environments |
| **Use Case** | Running different OS, full isolation | Microservices, application packaging |

**In Inception**: We use Docker containers for their lightweight nature and fast startup, perfect for a multi-service web infrastructure.

### Secrets vs Environment Variables

| Aspect | Docker Secrets | Environment Variables |
|--------|----------------|----------------------|
| **Storage** | Encrypted, stored in memory | Plain text in container |
| **Access** | Mounted as files in `/run/secrets/` | Available via `$VAR_NAME` |
| **Security** | More secure, not visible in logs | Can leak in logs, `docker inspect` |
| **Swarm Mode** | Required for full functionality | Works everywhere |
| **Use Case** | Passwords, API keys, certificates | Non-sensitive configuration |

**In Inception**: We use Docker secrets for passwords (db_password, db_root_password, credentials) and environment variables for non-sensitive config (domain name, database name).

### Docker Network vs Host Network

| Aspect | Docker Bridge Network | Host Network |
|--------|----------------------|--------------|
| **Isolation** | Containers isolated from host | Container uses host's network stack |
| **Port Mapping** | Explicit port mapping required | Container binds directly to host ports |
| **DNS** | Built-in DNS resolution by container name | Uses host's DNS |
| **Security** | More secure (network isolation) | Less secure (no network isolation) |
| **Performance** | Slight overhead | Native performance |

**In Inception**: We use a bridge network (`inception`) for security and container name DNS resolution. Containers communicate via internal names (e.g., `mariadb:3306`).

### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|----------------|-------------|
| **Management** | Managed by Docker | User manages host paths |
| **Location** | Docker storage area | Any host filesystem path |
| **Portability** | More portable | Tied to host structure |
| **Permissions** | Docker handles permissions | May have permission issues |
| **Backup** | Via Docker commands | Direct filesystem access |

**In Inception**: We use bind mounts (volumes with `type: none`) to store data in `/home/abogreek/data/` for easy access and backup from the host machine.

---

## Instructions

### Prerequisites

1. **Docker** and **Docker Compose** installed
2. Virtual Machine (as required by the project)
3. Add domain to hosts file:
   ```bash
   echo "127.0.0.1 abogreek.42.fr" | sudo tee -a /etc/hosts
   ```

### Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd Inception

# Start the infrastructure
make

# Check status
make status
```

### Available Commands

| Command | Description |
|---------|-------------|
| `make` or `make all` | Build and start all containers |
| `make build` | Build Docker images only |
| `make up` | Start containers |
| `make down` | Stop containers |
| `make clean` | Remove containers, images, and volumes |
| `make fclean` | Full clean including data directories |
| `make re` | Rebuild everything from scratch |
| `make logs` | View container logs |
| `make logs-f` | Follow logs in real-time |
| `make status` | Show container status |

### Accessing the Site

- **Website**: https://abogreek.42.fr
- **Admin Panel**: https://abogreek.42.fr/wp-admin

---

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Developer Resources](https://developer.wordpress.org/)

### Tutorials and Articles
- [Docker Getting Started Guide](https://docs.docker.com/get-started/)
- [Understanding Docker Networking](https://docs.docker.com/network/)
- [Docker Secrets in Compose](https://docs.docker.com/compose/use-secrets/)
- [NGINX as a Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

### AI Usage Disclosure

AI tools were used to assist with:
- **Documentation**: Generating initial drafts of README and documentation files
- **Code Review**: Reviewing Dockerfile syntax and best practices
- **Troubleshooting**: Debugging container networking issues

All AI-generated content was reviewed, verified, and modified as needed to ensure correctness and compliance with project requirements.

---

## Project Structure

```
Inception/
├── Makefile                  # Build automation
├── README.md                 # Project documentation
├── USER_DOC.md              # User documentation
├── DEV_DOC.md               # Developer documentation
├── .gitignore               # Git ignore rules
├── secrets/                 # Sensitive credentials (not in git)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                 # Environment variables
    ├── docker-compose.yml   # Container orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

---

## License

This project is part of the 42 school curriculum.
