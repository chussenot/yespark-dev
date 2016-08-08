user nginx;
worker_processes 3;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
  worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    proxy_cache_path   /tmp/assets levels=1:2 keys_zone=assets:2m max_size=1G;

    # Catch all on port 80 and redirect to 443 (https)
    server {
        listen 80       default_server;
        listen [::]:80  default_server ipv6only=on;
        return 301 https://$http_host$request_uri;
    }

    server {
        listen 443;
        server_name www.yespark.io ;

        ssl on;
        ssl_certificate     /etc/nginx/ssl/yespark.io.cert;
        ssl_certificate_key   /etc/nginx/ssl/yespark.io.key;

        location / {
            proxy_set_header Host $http_host;
            proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Real-IP         $remote_addr;
            proxy_redirect   off;
            proxy_pass       http://app:3000;
            proxy_read_timeout 150;
        }
    }
}
