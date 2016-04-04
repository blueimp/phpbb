# phpBB Dockerfile

FROM php:5.6-apache

MAINTAINER Sebastian Tschan <mail@blueimp.net>

# Install required packages:
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && apt-get install -y \
    libpng-dev \
    imagemagick \
    jq \
    bzip2 \
  # Install required PHP extensions:
  && docker-php-ext-install \
    gd \
    mysqli \
  # Remove obsolete files:
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /usr/share/doc/* \
    /var/cache/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Enable the Apache Rewrite module:
RUN ln -s /etc/apache2/mods-available/rewrite.load \
  /etc/apache2/mods-enabled/rewrite.load

# Enable the Apache Headers module:
RUN ln -s /etc/apache2/mods-available/headers.load \
  /etc/apache2/mods-enabled/headers.load

# Add the Apache security config:
COPY security.conf /etc/apache2/conf-enabled/

# Add the PHP config file:
COPY php.ini /usr/local/etc/php/

# Add a script to download and extract the latest stable phpBB version:
COPY download-phpbb.sh /usr/local/bin/download-phpbb

# Install phpBB into the Apache document root:
RUN download-phpbb /var/www \
  && rm -rf \
    /var/www/phpBB3/install \
    /var/www/phpBB3/docs \
    /var/www/html \
  && mv /var/www/phpBB3 /var/www/html

# Add the phpBB config file:
COPY config.php /var/www/html/

# Expose the phpBB upload directories as volumes:
VOLUME \
  /var/www/html/files \
  /var/www/html/store \
  /var/www/html/images/avatars/upload

ENV \
  DBHOST=mysql \
  DBPORT= \
  DBNAME=phpbb \
  DBUSER=phpbb \
  DBPASSWD= \
  TABLE_PREFIX=phpbb_
