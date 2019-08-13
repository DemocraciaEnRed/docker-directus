FROM php:7.1-apache
MAINTAINER aaraujo@protonmail.ch

# Environment variables
ENV PHP_OPCACHE_ENABLED true

# Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y git default-mysql-client libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev && apt-get clean

# Composer install
RUN curl https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# PHP modules and last settings
RUN docker-php-ext-install -j$(nproc) pdo_mysql mysqli && \
  docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
  docker-php-ext-install -j$(nproc) gd && \
  docker-php-ext-install opcache && \
  echo 'opcache.validate_timestamps=0\nopcache.enable=${PHP_OPCACHE_ENABLED}' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
  docker-php-ext-install mbstring && \
  docker-php-ext-install exif && pecl install imagick && a2enmod rewrite

# Directus install
RUN cd /var/www && curl https://codeload.github.com/directus/directus/tar.gz/6.4.9 | tar zxvf - && \
  rm -r /var/www/html && mv directus-6.4.9 /var/www/html && composer install -o -d /var/www/html

# Persistence patch
# These directories need persistency so they are backed up and moved in the entrypoint script
RUN cp -r /var/www/html/storage /var/www/html/storage.tmp && cp -r /var/www/html/api /var/www/html/api.tmp

# Configuration
COPY conf/000-default.conf /etc/apache2/sites-available/

COPY entrypoint.sh /entrypoint.sh
COPY conf/api_htaccess /var/www/html/api.tmp/.htaccess

CMD /entrypoint.sh
