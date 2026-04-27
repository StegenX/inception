FROM alpine:3.18

RUN apk add --no-cache redis

RUN mkdir -p /var/log/redis && \
    chown redis:redis /var/log/redis

EXPOSE 6379

CMD ["redis-server", "--protected-mode", "no", "--bind", "0.0.0.0", "--appendonly", "yes", "--logfile", "/var/log/redis/redis.log"]
