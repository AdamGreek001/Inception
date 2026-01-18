#!/bin/sh
# NGINX Setup Script for Inception

set -e

# Generate self-signed SSL certificate if not exists
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "Generating SSL certificate..."
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/OU=42/CN=eel-alao.42.fr"
    
    echo "SSL certificate generated successfully!"
fi

echo "Starting NGINX..."
exec nginx -g "daemon off;"
