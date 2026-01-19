#!/bin/sh

set -e

SSL_DIR=/etc/nginx/ssl

if [ ! -f ${SSL_DIR}/certs/inception.crt ]; then
    echo "Generating SSL certificate..."
    
    mkdir -p ${SSL_DIR}/certs ${SSL_DIR}/private
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ${SSL_DIR}/private/inception.key \
        -out ${SSL_DIR}/certs/inception.crt \
        -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/OU=42/CN=eel-alao.42.fr"
    
    echo "SSL certificate generated successfully!"
fi

echo "Starting NGINX..."
exec nginx -g "daemon off;"
