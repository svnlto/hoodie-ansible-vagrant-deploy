server {
  server_name www.example.com;
  return 301 $scheme://example.com$request_uri;
}

server {
  listen 80;
  server_name example.com;

  access_log /var/log/nginx/example.com.access_log;
  error_log /var/log/nginx/example.com.error_log warn;

  location / {
    root /home/deploy/example.com/stage/current/www;
    error_page 404 = /;
  }

  location ~ ^/_api(.*) {
    proxy_pass http://127.0.0.1:6001;
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;
  }

  location ~ ^/(.*)/_changes {
    proxy_pass http://127.0.0.1:6001;
    proxy_redirect off;
    proxy_buffering off;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;
  }

}

