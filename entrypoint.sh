#!/bin/bash

# Create extra directories
if [ ! -d  /var/www/html/api/logs ]; then
  echo '[INFO] Creating /var/www/html/api/logs'
  mkdir /var/www/html/api/logs
fi

if [ ! -d /var/www/html/media ]; then
  echo '[INFO] Creating /var/www/html/media'
  mkdir /var/www/html/media
fi

if [ ! -d /var/www/html/storage ]; then
  echo '[INFO] Creating /var/www/storage'
  mkdir /var/www/html/storage
fi

# If storage directory is mounted as a docker volume, then populate it.
echo '[INFO] Recreating /var/www/html/storage'
cp -r /var/www/html/storage.tmp/* /var/www/html/storage/

# If api directory is mounted as a docker volume, then populate it.
echo '[INFO] Recreating /var/www/html/api'
cp -r /var/www/html/api.tmp/* /var/www/html/api/
cp -r /var/www/html/api.tmp/.htaccess /var/www/html/api/

echo '[INFO] Initializing first run settings (if needed)'
if [ ! -f /var/www/html/api/configuration.php ]; then
    touch /var/www/html/api/configuration.php
fi

if [ ! -f /var/www/html/api/config.php ]; then
    touch /var/www/html/api/config.php
fi

if [ ! -d /var/www/html/vendor ]; then
  composer install
fi

chown -R www-data:www-data /var/www/html

# Helper functions
is_database_installed(){
  echo '[INFO] Checking if database has been initialized'
  tables=$(mysql -D $DIRECTUS_DB_SCHEMA -h $DIRECTUS_DB_HOST -u$DIRECTUS_DB_USER -P $DIRECTUS_DB_PORT -p$DIRECTUS_DB_PASSWORD --batch --skip-column-names -e "show tables")

  if [ $? -eq 0 ]; then
    if [ -z "$tables" ]; then
      echo '[INFO] Database is empty'
      return 1
    else
      echo '[INFO] Database is not empty'
      return 0
    fi
  else
    echo '[INFO] Error while connecting to database, exiting'
    exit 1
  fi
}

are_configs_generated(){
  echo '[INFO] Checking if settings have been initialized.'
  if [ -s /var/www/html/api/config.php -a -s /var/www/html/api/configuration.php ]; then
    return 0
  else
    return 1
  fi
}

# Directus setup
DIRECTUS_ADMIN_EMAIL="${DIRECTUS_ADMIN_EMAIL:-admin@admin.com}"
DIRECTUS_ADMIN_PASSWORD="${DIRECTUS_ADMIN_PASSWORD:-admin}"
DIRECTUS_SITE_NAME="${DIRECTUS_SITE_NAME:-directus}"
DIRECTUS_PATH="${DIRECTUS_PATH:-/}"

if ! are_configs_generated ; then
  /var/www/html/bin/directus install:config -h "$DIRECTUS_DB_HOST" -n "$DIRECTUS_DB_SCHEMA" -u "$DIRECTUS_DB_USER" -p "$DIRECTUS_DB_PASSWORD" -d "$DIRECTUS_PATH" -e "$DIRECTUS_ADMIN_EMAIL"
fi

if ! is_database_installed ; then
  /var/www/html/bin/directus install:database
  /var/www/html/bin/directus install:install -e "$DIRECTUS_ADMIN_EMAIL" -p "$DIRECTUS_ADMIN_PASSWORD" -t "$DIRECTUS_SITE_NAME"
fi

apache2-foreground
