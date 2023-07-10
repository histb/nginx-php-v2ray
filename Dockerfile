ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="slitazcn <teasiu@163.com>"
LABEL Description="Lightweight container with Nginx 1.24 & PHP 8.1 based on Alpine Linux."
# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  php81 \
  php81-ctype \
  php81-curl \
  php81-dom \
  php81-fpm \
  php81-gd \
  php81-intl \
  php81-mbstring \
  php81-mysqli \
  php81-opcache \
  php81-openssl \
  php81-phar \
  php81-session \
  php81-xml \
  php81-xmlreader \
  supervisor \
  wget \
  unzip 

RUN mkdir /etc/mysql /usr/local/mysql
COPY config/config.json /etc/mysql/
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
        wget -q -O v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-arm32-v7a.zip; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        wget -q -O v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-arm64-v8a.zip; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        wget -q -O v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip; \
    else \
        echo "Unsupported platform: $TARGETPLATFORM"; \
        exit 1; \
    fi

RUN unzip -d /usr/local/mysql v2ray.zip && \
	mv /usr/local/mysql/v2ray /usr/local/mysql/mysql && \
	chmod a+x /usr/local/mysql/mysql &&\
	rm v2ray.zip

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
COPY --chown=nobody src/ /var/www/html/
COPY --chown=nobody h5ai.tar.gz /var/www/html/
RUN tar -zxf h5ai.tar.gz -C /var/www/html/ &&\
	rm h5ai.tar.gz &&\
	chown -R nobody.nobody /var/www/html
	
# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
