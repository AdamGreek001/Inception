FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
    openssl \
    nginx \
    netcat-openbsd

WORKDIR /etc/nginx

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]
