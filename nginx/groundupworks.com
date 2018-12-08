server {
  listen 80;
  listen [::]:80;
  
  server_name .groundupworks.com;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl default_server;
  listen [::]:443 ssl default_server;

  root /var/www/groundupworks.com/html;
  index index.html index.htm index.nginx-debian.html;
  
  server_name .groundupworks.com;

  ssl_certificate /etc/nginx/ssl/groundupworks.com/fullchain.pem;
  ssl_certificate_key /etc/nginx/ssl/groundupworks.com/privkey.pem;
  ssl_trusted_certificate /etc/nginx/ssl/groundupworks.com/fullchain.pem;
  ssl_dhparam /etc/ssl/certs/dhparam.pem;

  # from https://cipherli.st/
  # and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
  ssl_ecdh_curve secp384r1;
  ssl_session_cache shared:SSL:10m;
  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.8.8 8.8.4.4 valid=300s;
  resolver_timeout 5s;
  # Disable preloading HSTS for now.  You can use the commented out header line that includes
  # the "preload" directive if you understand the implications.
  #add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
  add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;

  error_page 404 /index.html;
  location = /index.html {
    root /var/www/groundupworks.com/html;
    internal;
  }

  location / {
    # First attempt to serve request as file, then
    # as directory, then fall back to displaying a 404.
    try_files $uri $uri/ =404;
  }
}
