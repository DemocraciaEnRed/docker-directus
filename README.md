# Directus

Este container esta basado en un repositorio archivado llamado [directus-docker](https://github.com/directus/directus-docker) que tambien esta disponible en Docker Hub como [getdirectus/directus](https://hub.docker.com/r/getdirectus/directus). La version utilizada es Directus 6.9.4.

## Variables de Entorno

Se utilizan una serie de variables para la configuracion inicial de la aplicacion:

```
# Datos del servidor de base de datos (MySQL)
DIRECTUS_DB_HOST: mysql
DIRECTUS_DB_PORT: '3306'
DIRECTUS_DB_USER: directus
DIRECTUS_DB_PASSWORD: directus
DIRECTUS_DB_SCHEMA: directus

# Datos del administrador
DIRECTUS_ADMIN_EMAIL: admin@example.com
DIRECTUS_ADMIN_PASSWORD: secret1234
DIRECTUS_SITE_NAME: localhost
```

## Puerto

El servicio esta expuesto en el puerto 8080 del contenedor, en el directorio `conf/` se encuentra la configuracion de Apache aunque la modificacion implica hacer rebuild del container, montarlo como volumen es una tarea trivial.

## Volumenes

Durante la configuracion inicial se crean ficheros que luego se utilizan para decidir si es necesario crear la base de datos de directus o establecer valores por primera vez. Esto implica que dichos ficheros deben ser persistentes. Ademas el directorio `storage` requiere persistencia. Por lo tanto se establecen dos puntos a montar como volumenes de Docker.

**Storage**

El directorio del container `/var/www/html/storage` debe ser montado en un volumen.

**API**

El directorio del container `/var/www/html/api` debe ser montado en un volumen.

## Ejemplo

Se incluye un `docker-compose.yml` donde se ejemplifican todos los componentes anteriores. Es necesario utilizar una base de datos y una docker network dentro del compose.
