#!/usr/bin/env bash

BASEDIR=secrets
mkdir -p ${BASEDIR}

# generate the SSL certificate for server

PRIVKEY=${BASEDIR}/nuvla.key
PUBKEY=${BASEDIR}/nuvla.crt

rm -f ${PRIVKEY} ${PUBKEY}
openssl req \
        -newkey rsa:2048 \
        -nodes \
        -x509 \
        -days 14 \
        -subj "/C=EU/O=nuvla/CN=nuvla-test" \
        -keyout ${PRIVKEY} \
        -out ${PUBKEY}

#
# generate RSA certificate for session token signing
#

PRIVKEY=${BASEDIR}/session.key
PUBKEY=${BASEDIR}/session.crt

rm -f ${PRIVKEY} ${PUBKEY}
openssl genrsa -out ${PRIVKEY} 2048
openssl rsa -pubout -in ${PRIVKEY} -out ${PUBKEY}
