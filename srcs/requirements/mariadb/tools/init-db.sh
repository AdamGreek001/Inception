#!/bin/bash

chown -R mysql:mysql /var/lib/mysql
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

service mariadb start

echo "Waiting for MariaDB..."
sleep 3
while ! mysqladmin ping --silent 2>/dev/null; do
    sleep 1
done

DB_ROOT_PASS=$(cat /run/secrets/db_root_password)
DB_PASS=$(cat /run/secrets/db_password)

mariadb << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
FLUSH PRIVILEGES;
EOF

mysqladmin shutdown

exec mariadbd --user=mysql --bind-address=0.0.0.0 --datadir=/var/lib/mysql
