#!/usr/bin/env bash

BASEDIR=secrets
mkdir -p ${BASEDIR}

#
# generate RSA certificate for session token signing
#

PRIVKEY=${BASEDIR}/session.key
PUBKEY=${BASEDIR}/session.crt

rm -f ${PRIVKEY} ${PUBKEY}
openssl genrsa -out ${PRIVKEY} 2048
openssl rsa -pubout -in ${PRIVKEY} -out ${PUBKEY}
