FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    netcat-openbsd \
    default-mysql-client

WORKDIR /root

COPY ./tools/init-wordpress.sh ./init-wordpress.sh

RUN chmod +x ./init-wordpress.sh

ENTRYPOINT [ "bash", "./init-wordpress.sh" ]
