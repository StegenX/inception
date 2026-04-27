FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-cli \
    php-mysql \
    php-mbstring \
    php-json \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/adminer

RUN curl -fsSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o index.php && \
    chmod 644 index.php

RUN mkdir -p /var/log/adminer && \
    chown nobody:nogroup /var/log/adminer /var/www/adminer

COPY tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

USER nobody
EXPOSE 8080

CMD ["/usr/local/bin/start.sh"]
