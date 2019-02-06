# mjstealey.com - an example deployment

This example uses the default settings which is **STRONGLY** **DISCOURAGED** for real-world use. Once the documentation herein was completed this example was removed and the deployment was redone using better security principles.

## Prerequisites

- Server - example using a [Digital Ocean](https://www.digitalocean.com) droplet (Ubuntu 18.04)

  ```console
  # lsb_release -a
  No LSB modules are available.
  Distributor ID:	Ubuntu
  Description:	Ubuntu 18.04.1 LTS
  Release:	18.04
  Codename:	bionic
  ```
- Domain name - example using **mjstealey.com** from [GoDaddy](https://www.godaddy.com)
- DNS registry - ensure the A record associates the IP address of your server to the Domain name
- [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) and [Compose](https://docs.docker.com/compose/install/) installed on your server 

  ```console
  $ docker version
  Client:
   Version:           18.09.1
   API version:       1.39
   Go version:        go1.10.6
   Git commit:        4c52b90
   Built:             Wed Jan  9 19:35:31 2019
   OS/Arch:           linux/amd64
   Experimental:      false
  
  Server: Docker Engine - Community
   Engine:
    Version:          18.09.1
    API version:      1.39 (minimum version 1.12)
    Go version:       go1.10.6
    Git commit:       4c52b90
    Built:            Wed Jan  9 19:02:44 2019
    OS/Arch:          linux/amd64
    Experimental:     false
  $ docker-compose version
  docker-compose version 1.23.2, build 1110ad01
  docker-py version: 3.6.0
  CPython version: 3.6.7
  OpenSSL version: OpenSSL 1.1.0f  25 May 2017
  ```

## mjstealey.com

The deployment is being performed by a standard Linux user (`demouser`) that is a member of the **docker** group.

```console
$ id
uid=1000(demouser) 
gid=1000(demouser) 
groups=1000(demouser),27(sudo),110(lxd),999(docker)
```

Instructions will be written assuming that the user is at the top level of the cloned directory.

```console
git clone https://github.com/mjstealey/wordpress-nginx-docker.git
cd wordpress-nginx-docker/
```

### .env

Create the `.env` file

```
cp .env_example .env
```

Default values being used for `.env`:

```env
# wordpress - wordpress:php7.3-fpm
WORDPRESS_VERSION=php7.3-fpm
WORDPRESS_DB_NAME=wordpress
WORDPRESS_TABLE_PREFIX=wp_
WORDPRESS_DB_HOST=mysql
WORDPRESS_DB_USER=root
WORDPRESS_DB_PASSWORD=password

# mariadb - mariadb:latest
MARIADB_VERSION=latest
MYSQL_ROOT_PASSWORD=password
MYSQL_USER=root
MYSQL_PASSWORD=password
MYSQL_DATABASE=wordpress

# nginx - nginx:latest
NGINX_VERSION=latest

# volumes on host
NGINX_CONF_DIR=./nginx
NGINX_LOG_DIR=./logs/nginx
WORDPRESS_DATA_DIR=./wordpress
SSL_CERTS_DIR=./certs
SSL_CERTS_DATA_DIR=./certs-data
```

### https using Let's Encrypt

Create the `nginx/default.conf` file by copying the contents of `default_https.conf.template` and replacing **FQDN\_OR\_IP** with **mjstealey.com**

```
cp nginx/default_https.conf.template nginx/default.conf
sed -i 's/FQDN_OR_IP/mjstealey.com/g' nginx/default.conf
```

Updated `nginx/default.conf` file:

```nginx
server {
    listen      80;
    listen [::]:80;
    server_name mjstealey.com;

    location / {
        rewrite ^ https://$host$request_uri? permanent;
    }

    location ^~ /.well-known {
        allow all;
        root  /data/letsencrypt/;
    }
}

server {
    listen      443           ssl http2;
    listen [::]:443           ssl http2;
    server_name               mjstealey.com www.mjstealey.com;

    add_header                Strict-Transport-Security "max-age=31536000" always;

    ssl_session_cache         shared:SSL:20m;
    ssl_session_timeout       10m;

    ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers               "ECDH+AESGCM:ECDH+AES256:ECDH+AES128:!ADH:!AECDH:!MD5;";

    ssl_stapling              on;
    ssl_stapling_verify       on;
    resolver                  8.8.8.8 8.8.4.4;

    root /var/www/html;
    index index.php;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ssl_certificate           /etc/letsencrypt/live/mjstealey.com/fullchain.pem;
    ssl_certificate_key       /etc/letsencrypt/live/mjstealey.com/privkey.pem;
    ssl_trusted_certificate   /etc/letsencrypt/live/mjstealey.com/chain.pem;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

Make the directories as are specified in the `.env` file

```
mkdir -p certs/ certs-data/ logs/nginx/ mysql/ wordpress/
```

Run the `letsencrypt/letsencrypt-init.sh` script

```console
$ letsencrypt/letsencrypt-init.sh mjstealey.com
INFO: running from top level of repository
mysql uses an image, skipping
wordpress uses an image, skipping
nginx uses an image, skipping
Creating network "wordpress-nginx-docker_default" with the default driver
Creating mysql ... done
Creating wordpress ... done
Creating nginx     ... done
Unable to find image 'certbot/certbot:latest' locally
latest: Pulling from certbot/certbot
407ea412d82c: Pull complete
4aa45741b61e: Pull complete
2dc54ee2e6f3: Pull complete
4d994f02f15e: Pull complete
c038ebf87349: Pull complete
f161330ec17b: Pull complete
2e3bb278a0c8: Pull complete
536d789f6905: Pull complete
3679aad0a0e7: Pull complete
2e6a120db733: Pull complete
Digest: sha256:a12831b58d3add421f4e42df2def867cdfb5cedae5f559574e2a706349d58639
Status: Downloaded newer image for certbot/certbot:latest
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator webroot, Installer None
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): mjstealey@gmail.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server at
https://acme-v02.api.letsencrypt.org/directory
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(A)gree/(C)ancel: A

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about our work
encrypting the web, EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for mjstealey.com
http-01 challenge for www.mjstealey.com
Using the webroot path /data/letsencrypt for all unmatched domains.
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/mjstealey.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/mjstealey.com/privkey.pem
   Your cert will expire on 2019-05-07. To obtain a new or tweaked
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
INFO: update the nginx/default.conf file
-  4:   server_name mjstealey.com;
- 19:   server_name               mjstealey.com www.mjstealey.com;
- 40:   ssl_certificate           /etc/letsencrypt/live/mjstealey.com/fullchain.pem;
- 41:   ssl_certificate_key       /etc/letsencrypt/live/mjstealey.com/privkey.pem;
- 42:   ssl_trusted_certificate   /etc/letsencrypt/live/mjstealey.com/chain.pem;
```

### Deploy site mjstealey.com

At this point the site should be ready to deploy using the newly generated certificates

```console
$ docker-compose up -d
Creating mysql ... done
Creating wordpress ... done
Creating nginx     ... done
```

Allow a few moments for the containers to complete their setup process and go to: [https://mjstealey.com](https://mjstealey.com)

Follow the prompts and setup the site.

<img width="80%" alt="screen shot 2019-02-05 at 8 31 43 pm" src="https://user-images.githubusercontent.com/5332509/52315624-afe63680-2985-11e9-8ac3-ccc186e9114f.png">

<img width="80%" alt="screen shot 2019-02-05 at 8 32 59 pm" src="https://user-images.githubusercontent.com/5332509/52315625-afe63680-2985-11e9-8cb1-fd657e72ecb5.png">

<img width="80%" alt="screen shot 2019-02-05 at 8 33 13 pm" src="https://user-images.githubusercontent.com/5332509/52315626-b07ecd00-2985-11e9-8a1f-626c0a5e39cc.png">

<img width="80%" alt="screen shot 2019-02-05 at 8 33 39 pm" src="https://user-images.githubusercontent.com/5332509/52315627-b07ecd00-2985-11e9-981d-3a4ac703d143.png">

<img width="80%" alt="screen shot 2019-02-05 at 8 33 50 pm" src="https://user-images.githubusercontent.com/5332509/52315628-b07ecd00-2985-11e9-82a8-9057143610fc.png">

<img width="80%" alt="screen shot 2019-02-05 at 8 34 01 pm" src="https://user-images.githubusercontent.com/5332509/52315629-b1176380-2985-11e9-9994-506d350a1237.png">

Certificate information

<img width="80%" alt="screen shot 2019-02-05 at 8 38 32 pm" src="https://user-images.githubusercontent.com/5332509/52315703-1c613580-2986-11e9-950b-092c4a5df924.png">
