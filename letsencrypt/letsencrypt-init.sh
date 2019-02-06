#!/usr/bin/env bash

# check to see where the script is being run from and set local variables
if [ -f .env ]; then
  echo "INFO: running from top level of repository"
  source .env
  LE_DIR=$(pwd)/letsencrypt
else
  if [ ! -f ../.env ]; then
    echo "ERROR: Could not find the .env file?"
    exit 1;
  fi
  echo "INFO: running from the letsencrypt directory"
  source ../.env
  LE_DIR=$(pwd)
  cd ../
fi
REPO_DIR=$(dirname ${LE_DIR})

# get full directory path
if [ $(dirname ${SSL_CERTS_DIR}) = '.' ]; then
  CERTS=$REPO_DIR${SSL_CERTS_DIR:1}
else
  CERTS=${SSL_CERTS_DIR}
fi
if [ $(dirname ${SSL_CERTS_DATA_DIR}) = '.' ]; then
  CERTS_DATA=$REPO_DIR${SSL_CERTS_DATA_DIR:1}
else
  CERTS_DATA=${SSL_CERTS_DATA_DIR}
fi

# Nginx config file for using Let's Encrypt
_lets_encrypt_conf () {
  local OUTFILE=lets_encrypt.conf
  cat > $OUTFILE <<EOF
server {
    listen      80;
    listen [::]:80;
    server_name ${FQDN_OR_IP};

    location / {
        rewrite ^ https://\$host\$request_uri? permanent;
    }

    location ^~ /.well-known {
        allow all;
        root  /data/letsencrypt/;
    }
}
EOF
}

# FQDN_OR_IP should not include prefix of www.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 FQDN_OR_IP" >&2
    exit 1;
else
    FQDN_OR_IP=$1
fi

if [ ! -d "${CERTS}" ]; then
    echo "INFO: making certs directory"
    mkdir ${CERTS}
fi

if [ ! -d "${CERTS_DATA}" ]; then
    echo "INFO: making certs-data directory"
    mkdir ${CERTS_DATA}
fi

# Launch Nginx container with CERTS and CERTS_DATA mounts
cd ${LE_DIR}
_lets_encrypt_conf
cd ${REPO_DIR}
docker-compose build

# rename default.conf temporarily
if [ -e ${REPO_DIR}/nginx/default.conf ]; then
  mv ${REPO_DIR}/nginx/default.conf ${REPO_DIR}/nginx/default.conf.waitforletsencrypt
fi

docker-compose up -d
sleep 5s
docker cp ${LE_DIR}/lets_encrypt.conf nginx:/etc/nginx/conf.d/lets_encrypt.conf
docker exec nginx /usr/sbin/nginx -s reload
sleep 5s
cd ${LE_DIR}

docker run -it --rm \
    -v ${CERTS}:/etc/letsencrypt \
    -v ${CERTS_DATA}:/data/letsencrypt \
    certbot/certbot \
    certonly \
    --webroot --webroot-path=/data/letsencrypt \
    -d ${FQDN_OR_IP} -d www.${FQDN_OR_IP}

cd ${REPO_DIR}
docker-compose stop
docker-compose rm -f

# reset default.conf if it was changed
if [ -e ${REPO_DIR}/nginx/default.conf.waitforletsencrypt ]; then
  mv ${REPO_DIR}/nginx/default.conf.waitforletsencrypt ${REPO_DIR}/nginx/default.conf
fi

cd ${LE_DIR}
rm -f ${REPO_DIR}/lets_encrypt.conf

echo "INFO: update the nginx/default.conf file"
echo "-  4:   server_name ${FQDN_OR_IP};"
echo "- 19:   server_name               ${FQDN_OR_IP} www.${FQDN_OR_IP};"
echo "- 40:   ssl_certificate           /etc/letsencrypt/live/${FQDN_OR_IP}/fullchain.pem;"
echo "- 41:   ssl_certificate_key       /etc/letsencrypt/live/${FQDN_OR_IP}/privkey.pem;"
echo "- 42:   ssl_trusted_certificate   /etc/letsencrypt/live/${FQDN_OR_IP}/chain.pem;"

exit 0;
