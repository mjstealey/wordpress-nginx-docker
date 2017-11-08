#!/usr/bin/env bash

LE_DIR=$(pwd)
REPO_DIR=$(dirname ${LE_DIR})
CERTS=${REPO_DIR}/certs
CERTS_DATA=${REPO_DIR}/certs-data

# DOMAIN_NAME should not include prefix of www.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 DOMAIN_NAME" >&2
    exit 1;
else
    DOMAIN_NAME=$1
fi

if [ ! -d "${CERTS}/live/${DOMAIN_NAME}" ]; then
    echo "INFO: making certs directory"
    mkdir -p ${CERTS}/live/${DOMAIN_NAME}
fi

# generate and add keys
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
    -days 365 -nodes -subj '/CN='${DOMAIN_NAME}''

mv cert.pem ${CERTS}/live/${DOMAIN_NAME}/fullchain.pem
mv key.pem ${CERTS}/live/${DOMAIN_NAME}/privkey.pem

echo "INFO: update the nginx/wordpress_ssl.conf file"
echo "-  4:   server_name ${DOMAIN_NAME};"
echo "- 19:   server_name               ${DOMAIN_NAME} www.${DOMAIN_NAME};"
echo "- 46:   ssl_certificate           /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;"
echo "- 47:   ssl_certificate_key       /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;"
echo "- 48:   #ssl_trusted_certificate   /etc/letsencrypt/live/DOMAIN_NAME/chain.pem; <-- COMMENT OUT OR REMOVE"

exit 0;