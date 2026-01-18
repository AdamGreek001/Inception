# NGINX Container for Inception
# Based on Alpine 3.19 (penultimate stable)

FROM alpine:3.19

# Install NGINX and OpenSSL
RUN apk update && apk add --no-cache \
    nginx \
    openssl

# Create directories
RUN mkdir -p /etc/nginx/ssl /var/www/html /run/nginx

# Copy configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Expose HTTPS port only
EXPOSE 443

# Run setup script which starts nginx
ENTRYPOINT ["/usr/local/bin/setup.sh"]
