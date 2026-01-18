# WordPress + PHP-FPM Container for Inception
# Based on Alpine 3.19 (penultimate stable)

FROM alpine:3.19

# Install PHP and required extensions for WordPress
RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-gd \
    php82-iconv \
    php82-intl \
    php82-phar \
    php82-ctype \
    php82-session \
    php82-tokenizer \
    php82-pecl-redis \
    wget \
    curl \
    mariadb-client

# Install WP-CLI
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Create symbolic link for php
RUN ln -sf /usr/bin/php82 /usr/bin/php

# Configure PHP-FPM
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

# Create WordPress directory
RUN mkdir -p /var/www/html \
    && chown -R nobody:nobody /var/www/html

# Copy initialization script
COPY tools/init-wordpress.sh /usr/local/bin/init-wordpress.sh
RUN chmod +x /usr/local/bin/init-wordpress.sh

# Set working directory
WORKDIR /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Run initialization script
ENTRYPOINT ["/usr/local/bin/init-wordpress.sh"]
