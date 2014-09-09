# Nginx Reverse Proxy for Docker Containers with PageSpeed
---

## Build

	docker build -t munjalpatel/nginx-docker-proxy .

## Run

	docker run -d -p 80:80 -p 443:443 -v $(pwd)/sites-enabled:/etc/nginx/sites-enabled -v /var/run/docker.sock:/tmp/docker.sock munjalpatel/nginx-docker-proxy
    
## Running Service Containers

    docker run -e VIRTUAL_HOST=foo.bar.com  ...