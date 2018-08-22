# wordpress-nginx-docker

Docker compose installation of a single site Wordpress instance using Nginx as the web server and MariaDB as the database.

Let's Encrypt SSL enabled option using [https://hub.docker.com/r/certbot/certbot/](https://hub.docker.com/r/certbot/certbot/)

Work inspired by: [Dockerizing Wordpress with Nginx and PHP-FPM on Ubuntu 16.04](https://www.howtoforge.com/tutorial/dockerizing-wordpress-with-nginx-and-php-fpm/)

## Installation

Review the [Optional configuration](#opt_config) options and determine if you'd like to apply any.

### Create directories on host

Directories are created on the host to persist data for the containers to volume mount from the host.

- **mysql**: The database files for MariaDB
- **wordpress**: The WordPress media files
- **logs/nginx**: The Nginx log files (error.log, access.log)
- **certs**: SSL certificate files (LetsEncrypt)
- **certs-data**: SSL challenge/response area (LetsEncrypt)

From the top level of the cloned repository, create the directories that will be used for managing the data on the host.

```
$ cd wordpress-nginx-docker/
# mkdir -p certs/ certs-data/ logs/nginx/ mysql/ wordpress/
```

### HTTP

If you plan to run your WordPress site over http on port 80, then do the following.

1. Change the name of `nginx/wordpress.conf.example` to `nginx/wordpress.conf` 
2. Update the `DOMAIN_NAME` in `nginx/wordpress.conf` to be that of your domain
3. Run `$ docker-compose up -d`
4. Navigate to [http://DOMAIN_NAME]() in a browser where `DOMAIN_NAME` is the name of your site

### HTTPS with SSL Certificates

If you plan to run your WordPress site over https on port 443, then do the following.

**Choose a method for SSL certificates**

- **Let's Encrypt**

    If you plan on using SSL certificates from [Let's Encrypt](https://letsencrypt.org) it is important that your public domain is already DNS registered and publically reachable.
	
    Run: `./letsencrypt/letsencrypt-init.sh DOMAIN_NAME`, where `DOMAIN_NAME` is the publicly registered domain name of your host to generate your initial certificate. (Information about updating your Let's Encrypt certificate can be found further down in this document)

```console
$ ./letsencrypt-init.sh example.com
mysql uses an image, skipping
wordpress uses an image, skipping
nginx uses an image, skipping
Creating mysql ...
Creating mysql ... done
Creating wordpress ...
Creating wordpress ... done
Creating nginx ...
Creating nginx ... done
Reloading nginx: nginx.
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator webroot, Installer None
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): mjstealey@gmail.com

-------------------------------------------------------------------------------
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf. You must agree
in order to register with the ACME server at
https://acme-v01.api.letsencrypt.org/directory
-------------------------------------------------------------------------------
(A)gree/(C)ancel: a

-------------------------------------------------------------------------------
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about EFF and
our work to encrypt the web, protect its users and defend digital rights.
-------------------------------------------------------------------------------
(Y)es/(N)o: y
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for example.com
http-01 challenge for www.example.com
Using the webroot path /data/letsencrypt for all unmatched domains.
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
    ssl                       on;
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/example.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/example.com/privkey.pem
   Your cert will expire on 2018-02-06. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

Stopping nginx     ... done
Stopping wordpress ... done
Stopping mysql     ... done
Going to remove nginx, wordpress, mysql
Removing nginx     ... done
Removing wordpress ... done
Removing mysql     ... done
INFO: update the nginx/wordpress_ssl.conf file
-  4:   server_name example.com;
- 19:   server_name               example.com www.example.com;
- 46:   ssl_certificate           /etc/letsencrypt/live/example.com/fullchain.pem;
- 47:   ssl_certificate_key       /etc/letsencrypt/live/example.com/privkey.pem;
- 48:   ssl_trusted_certificate   /etc/letsencrypt/live/example.com/chain.pem;
```
	
- **Self signed**

	If you plan on using self signed SSL certificates, run: `./letsencrypt/self-signed-init.sh DOMAIN_NAME`, where `DOMAIN_NAME` is the `CN` you want to assign to the host (commonly `localhost`).
	
```console
$ cd letsencrypt/
$ ./self-signed-init.sh localhost
INFO: making certs directory
Generating a 4096 bit RSA private key
................................................................................................................................................................................................................................................++
....................................................++
writing new private key to 'key.pem'
-----
INFO: update the nginx/wordpress_ssl.conf file
-  4:   server_name localhost;
- 19:   server_name               localhost www.localhost;
- 46:   ssl_certificate           /etc/letsencrypt/live/localhost/cert.pem;
- 47:   ssl_certificate_key       /etc/letsencrypt/live/localhost/privkey.pem;
- 48:   #ssl_trusted_certificate   /etc/letsencrypt/live/DOMAIN_NAME/chain.pem; <-- COMMENT OUT OR REMOVE
```

- **Bring your own**

    If you plan to use pre-existing certificates you will need to update the `nginx/wordpress_ssl.conf` file with the appropriate settings to the kind of certificates you have.

**Finally**

1. Change the name of `nginx/wordpress_ssl.conf.example` to `nginx/wordpress_ssl.conf` 
2. Update the `DOMAIN_NAME` in `nginx/wordpress_ssl.conf` to be that of your domain
3. Run `$ docker-compose up -d`
4. Navigate to [https://DOMAIN_NAME]() in a browser where `DOMAIN_NAME` is the name of your site

### Updating your Let's Encrypt certificate

What is the lifetime for Let’s Encrypt certificates? For how long are they valid?

- Let's Encrypt certificates are valid for 90 days. You can read about why [here](https://letsencrypt.org/2015/11/09/why-90-days.html).
- There is no way to adjust this, there are no exceptions. Let's Encrypt recommends automatically renewing your certificates every 60 days.

A script named [letsencrypt-renew.sh](letsencrypt/letsencrypt-renew.sh) has been provided to update your certificate as needed. This script can be run at any time along side of your already running site, and if the certificate is due for renewal, it will be renewed. If it is still valid or not yet close to the expiry date, then you'll see a `Cert not yet due for renewal` message such as the one below.

```console
$ ./letsencrypt-renew.sh
Saving debug log to /var/log/letsencrypt/letsencrypt.log

-------------------------------------------------------------------------------
Processing /etc/letsencrypt/renewal/example.com.conf
-------------------------------------------------------------------------------
Cert not yet due for renewal

-------------------------------------------------------------------------------

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/example.com/fullchain.pem (skipped)
No renewals were attempted.
-------------------------------------------------------------------------------
Killing nginx ... done
```

This script can be scheduled to run via a cron task every 15 days or so to ensure an automatic renewal of your certificate.

## <a name="opt_config"></a>Optional Configuration

### Environment Varialbles

WordPress environment variables. See the [official image](https://hub.docker.com/_/wordpress/) for additional information.

- `WORDPRESS_DB_NAME`: Name of database used for WordPress in MariaDB
- `WORDPRESS_TABLE_PREFIX`: Prefix appended to all WordPress related tables in the `WORDPRESS_DB_NAME` database
- `WORDPRESS_DB_HOST `: Hostname of the database server / container
- `WORDPRESS_DB_PASSWORD `: Database password for the `WORDPRESS_DB_USER`. By default 'root' is the `WORDPRESS_DB_USER`.

```yaml
    environment:
      - WORDPRESS_DB_NAME=wordpress
      - WORDPRESS_TABLE_PREFIX=wp_
      - WORDPRESS_DB_HOST=mysql
      - WORDPRESS_DB_PASSWORD=password
```

MySQL environment variables.

- If you've altered the `WORDPRESS_DB_PASSWORD` you should also set the `MYSQL_ROOT_PASSWORD ` to be the same as they will both be associated with the user 'root'.

```yaml
    environment:
      - MYSQL_ROOT_PASSWORD=password
```

### Non-root database user

If you don't want 'root' as the `WORDPRESS_DB_USER`, then some extra configuration variables are required in the `mysql` container.

Example:

```yaml
version: '3.6'
services:
  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./nginx:/etc/nginx/conf.d
      - ./logs/nginx:/var/log/nginx
      - ./wordpress:/var/www/html
      - ./certs:/etc/letsencrypt
      - ./certs-data:/data/letsencrypt
    links:
      - wordpress
    restart: always

  mysql:
    image: mariadb
    container_name: mysql
    volumes:
      - ./mysql:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_USER=wp_user                 # same as WORDPRESS_DB_USER
      - MYSQL_PASSWORD=wp_password         # same as WORDPRESS_DB_PASSWORD
      - MYSQL_DATABASE=wordpress           # same as WORDPRESS_DB_NAME
    restart: always

  wordpress:
    image: wordpress:php7.2-fpm
    container_name: wordpress
    volumes:
      - ./wordpress:/var/www/html
    environment:
      - WORDPRESS_DB_NAME=wordpress
      - WORDPRESS_TABLE_PREFIX=wp_
      - WORDPRESS_DB_HOST=mysql
      - WORDPRESS_DB_PASSWORD=wp_password  # new DB password
      - WORDPRESS_DB_USER=wp_user          # new DB user
    links:
      - mysql
    restart: always
```

## Example deployment (using localhost)

From the top level of the cloned repository, create host directories to preserve the container contents and create a basic Nginx configuration file.

```
cd wordpress-nginx-docker/
### optional: directories would be created by docker if not done manually
mkdir -p certs/ certs-data/ logs/nginx/ mysql/ wordpress/
cp nginx/wordpress.conf.example nginx/wordpress.conf
```

Update `nginx/wordpress.conf` by changing the `server_name` value from `DOMAIN_NAME` to `127.0.0.1`.

```console
$ diff nginx/wordpress.conf.example nginx/wordpress.conf
3c3
<     server_name DOMAIN_NAME;
---
>     server_name 127.0.0.1;
```

Launch and daemonize the containers with `docker-compose up -d`

```console
$ docker-compose up -d
Creating mysql ... done
Creating wordpress ... done
Creating nginx     ... done
```

### Initial Wordpress setup

Navigate your browser to [http://127.0.0.1](http://127.0.0.1) and follow the installation prompts

1. Set language

    <img width="80%" alt="Select language" src="https://user-images.githubusercontent.com/5332509/44045885-f47a89fe-9ef7-11e8-8dae-0df0bfb269de.png">
2. Create an administrative user

    <img width="80%" alt="Create admin user" src="https://user-images.githubusercontent.com/5332509/44045887-f4897cfc-9ef7-11e8-89c6-cfc96cfc9ca0.png">

3. Success

    <img width="80%" alt="Success" src="https://user-images.githubusercontent.com/5332509/44045888-f49b344c-9ef7-11e8-9d65-39517f521d85.png">
    
4. Log in as the administrative user, dashboard, view site

    <img width="80%" alt="First login" src="https://user-images.githubusercontent.com/5332509/44045889-f4a71992-9ef7-11e8-8f5d-8ab16da481c2.png">
    
    <img width="80%" alt="Site dashboard" src="https://user-images.githubusercontent.com/5332509/44045890-f4b4b264-9ef7-11e8-935b-cbc546cd9e00.png">
    
    <img width="80%" alt="View site" src="https://user-images.githubusercontent.com/5332509/44045891-f4c5f90c-9ef7-11e8-88e4-fc8cfb61ea7d.png">
    
    
Once your site is running you can begin to create and publish any content you'd like in your Wordpress instance.


### Port Mapping

Neither the **mysql** container nor the **wordpress** container have publicly exposed ports. They are running on the host using a docker defined network which provides the containers with access to each others ports, but not from the host.

If you wish to expose the ports to the host, you'd need to alter the stanzas for each in the `docker-compose.yml` file.

For the `mysql` stanza, add

```
    ports:
      - '3306:3306'
```

For the `wordpress` stanza, add

```
    ports:
      - '9000:9000'
```

## Clean up / Removal

Because docker-compose was used to define the container relationships it can also be used to stop and remove the containers from the host they are running on.

Stop and remove containers:

```console
$ cd wordpress-nginx-docker
$ docker-compose stop
Stopping nginx     ... done
Stopping wordpress ... done
Stopping mysql     ... done
$ docker-compose rm -f
Going to remove nginx, wordpress, mysql
Removing nginx     ... done
Removing wordpress ... done
Removing mysql     ... done
```

Removing all related directories:

```console
$ rm -rf certs/ certs-data/ logs/ mysql/ wordpress/
```
