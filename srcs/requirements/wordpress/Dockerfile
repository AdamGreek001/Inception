FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    netcat-openbsd \
    default-mysql-client

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /root

COPY ./tools/init-wordpress.sh ./init-wordpress.sh

RUN chmod +x ./init-wordpress.sh

ENTRYPOINT [ "bash", "./init-wordpress.sh" ]
