#!/usr/bin/env bash

LE_DIR=$(pwd)
REPO_DIR=$(dirname ${LE_DIR})
CERTS=${REPO_DIR}/certs
CERTS_DATA=${REPO_DIR}/certs-data

_default_conf () {
    local OUTFILE=default.conf
    echo "server {" > $OUTFILE
    echo "    listen      80;" >> $OUTFILE
    echo "    listen [::]:80;" >> $OUTFILE
    echo "    server_name ${DOMAIN_NAME};" >> $OUTFILE
    echo "" >> $OUTFILE
    echo "    location / {" >> $OUTFILE
    echo "        rewrite ^ https://\$host\$request_uri? permanent;" >> $OUTFILE
    echo "    }" >> $OUTFILE
    echo "" >> $OUTFILE
    echo "    location ^~ /.well-known {" >> $OUTFILE
    echo "        allow all;" >> $OUTFILE
    echo "        root  /data/letsencrypt/;" >> $OUTFILE
    echo "    }" >> $OUTFILE
    echo "}" >> $OUTFILE
}

# DOMAIN_NAME should not include prefix of www.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 DOMAIN_NAME" >&2
    exit 1;
else
    DOMAIN_NAME=$1
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
_default_conf
cd ${REPO_DIR}
docker-compose build
docker-compose up -d
sleep 5s
docker cp ${LE_DIR}/default.conf nginx:/etc/nginx/conf.d/default.conf
docker exec nginx /etc/init.d/nginx reload
sleep 5s
cd ${LE_DIR}

docker run -it --rm \
    -v ${CERTS}:/etc/letsencrypt \
    -v ${CERTS_DATA}:/data/letsencrypt \
    certbot/certbot \
    certonly \
    --webroot --webroot-path=/data/letsencrypt \
    -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME}

cd ${REPO_DIR}
docker-compose stop
docker-compose rm -f
cd ${LE_DIR}
rm -f ${REPO_DIR}/nginx/default.conf

echo "INFO: update the nginx/wordpress_ssl.conf file"
echo "-  4:   server_name ${DOMAIN_NAME};"
echo "- 19:   server_name               ${DOMAIN_NAME} www.${DOMAIN_NAME};"
echo "- 46:   ssl_certificate           /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;"
echo "- 47:   ssl_certificate_key       /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;"
echo "- 48:   ssl_trusted_certificate   /etc/letsencrypt/live/${DOMAIN_NAME}/chain.pem;"

exit 0;