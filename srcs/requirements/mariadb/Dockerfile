# MariaDB Container for Inception
# Based on Alpine 3.19 (penultimate stable)

FROM alpine:3.19

# Install MariaDB
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-common

# Create required directories
RUN mkdir -p /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy configuration
COPY conf/50-server.cnf /etc/my.cnf.d/50-server.cnf

# Copy initialization script
COPY tools/init-db.sh /usr/local/bin/init-db.sh
RUN chmod +x /usr/local/bin/init-db.sh

# Expose MariaDB port
EXPOSE 3306

# Run initialization script
ENTRYPOINT ["/usr/local/bin/init-db.sh"]
