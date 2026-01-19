FROM debian:bookworm

ARG SSL_DIR=/etc/nginx/ssl

RUN apt-get update && \
    apt-get install -y \
    openssl \
    nginx \
    netcat-openbsd

RUN mkdir -p ${SSL_DIR}/certs ${SSL_DIR}/private && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ${SSL_DIR}/private/inception.key \
    -out ${SSL_DIR}/certs/inception.crt \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/OU=42/CN=eel-alao.42.fr"

WORKDIR /etc/nginx

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]
