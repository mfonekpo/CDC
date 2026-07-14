location /prometheus/ {
    proxy_pass http://prometheus:9090/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Protect against long-running dashboard timeouts
    proxy_read_timeout 180s;
    proxy_connect_timeout 180s;
}