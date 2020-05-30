server {
        listen 8080;
        root /var/www/wordpressexample.com;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name wordpressexample.com;
        client_max_body_size 64M;

        location / {
                # This is cool because no php is touched for static content
                try_files $uri $uri/ /index.php;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }

        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }
}

server {
        listen 443 ssl;

        server_name wordpressexample.com;
        ssl_certificate /etc/letsencrypt/live/wordpressexample.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/wordpressexample.com/privkey.pem;

        location / {
            proxy_pass http://127.0.0.1:80;
            proxy_set_header X-Real-IP  $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Port 443;
            proxy_set_header Host $host;
        }
}