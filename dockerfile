FROM openresty/openresty
RUN mkdir -p /mnt/
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
