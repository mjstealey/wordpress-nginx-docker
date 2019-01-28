#!/usr/bin/env bash

LE_DIR=$(pwd)
REPO_DIR=$(dirname ${LE_DIR})
CERTS=${REPO_DIR}/certs
CERTS_DATA=${REPO_DIR}/certs-data

# FQDN_OR_IP should not include prefix of www.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 FQDN_OR_IP" >&2
    exit 1;
else
    FQDN_OR_IP=$1
fi

if [ ! -d "${CERTS}/live/${FQDN_OR_IP}" ]; then
    echo "INFO: making certs directory"
    mkdir -p ${CERTS}/live/${FQDN_OR_IP}
fi

# generate and add keys
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
    -days 365 -nodes -subj '/CN='${FQDN_OR_IP}''

mv cert.pem ${CERTS}/live/${FQDN_OR_IP}/fullchain.pem
mv key.pem ${CERTS}/live/${FQDN_OR_IP}/privkey.pem

echo "INFO: update the nginx/default.conf file"
echo "-  4:   server_name ${FQDN_OR_IP};"
echo "- 19:   server_name               ${FQDN_OR_IP} www.${FQDN_OR_IP};"
echo "- 40:   ssl_certificate           /etc/letsencrypt/live/${FQDN_OR_IP}/fullchain.pem;"
echo "- 41:   ssl_certificate_key       /etc/letsencrypt/live/${FQDN_OR_IP}/privkey.pem;"
echo "- 42:   #ssl_trusted_certificate   /etc/letsencrypt/live/FQDN_OR_IP/chain.pem; <-- COMMENT OUT OR REMOVE"

exit 0;
