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

	If you plan on using SSL certificates from [Let's Encrypt](https://letsencrypt.org) it is important that your public domain is already registered and reachable.
	
	Run: `./letsencrypt/letsencrypt-init.sh DOMAIN_NAME`, where `DOMAIN_NAME` is the publicly registered domain name of your host.
	
	```
	$ cd letsencrypt/
	$ ./letsencrypt-init.sh example.com
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
	cancel): example@ example.com
	
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
	    ssl                       on;
	
	IMPORTANT NOTES:
	 - Congratulations! Your certificate and chain have been saved at:
	   /etc/letsencrypt/live/example.com/fullchain.pem
	   Your key file has been saved at:
	   /etc/letsencrypt/live/example.com/privkey.pem
	   Your cert will expire on 2018-02-05. To obtain a new or tweaked
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
	
	Stopping nginx ... done
	Going to remove nginx
	Removing nginx ... done
	INFO: update the nginx/wordpress_ssl.conf file
	-  4:   server_name 			  example.com;
	- 19:   server_name               example.com www. example.com;
	- 46:   ssl_certificate           /etc/letsencrypt/live/example.com/fullchain.pem;
	- 47:   ssl_certificate_key       /etc/letsencrypt/live/example.com/privkey.pem;
	- 48:   ssl_trusted_certificate   /etc/letsencrypt/live/example.com/chain.pem;
		```

- **Self signed**

	If you plan on using self signed SSL certificates, run: `./letsencrypt/self-signed-init.sh DOMAIN_NAME`, where `DOMAIN_NAME` is the `CN` you want to assign to the host (commonly `localhost`).
	
	```
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

### Port Mapping

Neither the **mysql** container nor the **wordpress** container have publicly exposed ports. They are running on the host using a docker defined network named `wp_network` which provides the containers with access to each others ports, but not from the host.

If you wish to expose the ports to the host, you'd need to alter the stanzas for each in the `docker-compose.yaml` file.

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

Removing all related containers

```
$ cd wordpress-nginx-docker/
$ docker-compose stop
$ docker-compose rm -f
```

Removing all related directories

```
$ cd wordpress-nginx-docker/
$ rm -rf certs/ certs-data/ logs/ mysql/ wordpress/
```
