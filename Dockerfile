FROM google/debian:wheezy
MAINTAINER Munjal Patel <munjal@munpat.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq \
	&& apt-get install -yqq build-essential zlib1g-dev libpcre3 libpcre3-dev openssl libssl-dev libperl-dev wget ca-certificates \
	&& (wget -qO - https://github.com/pagespeed/ngx_pagespeed/archive/v1.8.31.4-beta.tar.gz | tar zxf - -C /tmp) \
	&& (wget -qO - https://dl.google.com/dl/page-speed/psol/1.8.31.4.tar.gz | tar zxf - -C /tmp/ngx_pagespeed-1.8.31.4-beta/) \
	&& (wget -qO - http://nginx.org/download/nginx-1.7.4.tar.gz | tar zxf - -C /tmp) \
	&& cd /tmp/nginx-1.7.4 \
	&& ./configure --prefix=/etc/nginx/ --sbin-path=/usr/sbin/nginx --add-module=/tmp/ngx_pagespeed-1.8.31.4-beta --with-http_ssl_module --with-http_spdy_module \
	&& make install \
	&& rm -Rf /tmp/*
  
RUN mkdir /app
WORKDIR /app
ADD . /app

RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego
RUN chmod u+x /usr/local/bin/forego

RUN wget https://github.com/jwilder/docker-gen/releases/download/0.3.3/docker-gen-linux-amd64-0.3.3.tar.gz
RUN tar xvzf docker-gen-linux-amd64-0.3.3.tar.gz

ENV DOCKER_HOST unix:///tmp/docker.sock
  
RUN apt-get purge -yqq wget build-essential \
	&& apt-get autoremove -yqq \
	&& apt-get clean

EXPOSE 80 443

VOLUME ["/etc/nginx/sites-enabled"]
WORKDIR /etc/nginx/

# Configure nginx
RUN mkdir /var/ngx_pagespeed_cache
RUN chmod 777 /var/ngx_pagespeed_cache
COPY proxy_params /etc/nginx/proxy_params
COPY nginx.conf /etc/nginx/conf/nginx.conf
COPY sites-enabled /etc/nginx/sites-enabled
COPY nginx.crt /etc/nginx/certs/nginx.crt
COPY nginx.key /etc/nginx/certs/nginx.key

WORKDIR /app
CMD ["forego", "start", "-r"]