FROM debian:bookworm

RUN apt-get update -y && \
	apt-get install -y \
	mariadb-server

COPY tools/init-db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init-db.sh

ENTRYPOINT ["/usr/local/bin/init-db.sh"]
