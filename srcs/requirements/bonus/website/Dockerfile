FROM alpine:3.18

RUN apk update && apk add --no-cache nginx

RUN rm -rf /etc/nginx/conf.d/default.conf

COPY html /var/www/html
COPY tools/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh && \
    chown -R nobody:nobody /var/www/html

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
