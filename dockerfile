FROM openresty/openresty
RUN mkdir -p /mnt/certs
COPY certs/. /mnt/certs/
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
