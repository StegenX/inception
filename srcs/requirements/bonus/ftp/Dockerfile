FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    vsftpd \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/vsftpd && \
    mkdir -p /var/run/vsftpd/empty && \
    mkdir -p /home/ftp/wordpress && \
    chmod 555 /var/run/vsftpd/empty && \
    echo "/bin/false" >> /etc/shells

COPY tools/vsftpd.conf /etc/vsftpd.conf
COPY tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 20 21 21100-21200

CMD ["/usr/local/bin/start.sh"]
