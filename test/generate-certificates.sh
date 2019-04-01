#!/usr/bin/env bash

# generate the SSL certificate for server

PRIVKEY=traefik/nuvla.key
PUBKEY=traefik/nuvla.crt

mkdir -p traefik
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

PRIVKEY=session/session.key
PUBKEY=session/session.cert

mkdir -p session
rm -f ${PRIVKEY} ${PUBKEY}
openssl genrsa -out ${PRIVKEY} 2048
openssl rsa -pubout -in ${PRIVKEY} -out ${PUBKEY}
chmod 400 ${PRIVKEY} ${PRIVKEY}
