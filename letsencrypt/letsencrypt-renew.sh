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

# certs and certs-data directory expected to already exist and
# contain prior certificate information
if [ ! -d "${CERTS}" ]; then
    echo "WARNING: no certs directory!"
    exit 1;
fi

if [ ! -d "${CERTS_DATA}" ]; then
    echo "WARNING: no certs-data directory!"
    exit 1;
fi

docker run -t --rm \
    -v ${CERTS}:/etc/letsencrypt \
    -v ${CERTS_DATA}:/data/letsencrypt \
    certbot/certbot \
    renew \
    --webroot --webroot-path=/data/letsencrypt

cd ${REPO_DIR}
docker-compose kill -s HUP nginx
cd ${LE_DIR}

exit 0;
