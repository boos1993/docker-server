#!/bin/bash
# Thanks for the jump-start!:
#   https://gist.github.com/Stono/7e6fed13cfd79598eb15#file-create-docker-tls-sh
#
# This script will help you generate certs for docker TLS auth.
# To run it, you pass the wildcard to your custom domain name
#
# For example:
#    ./setup-docker-tls.sh *.mydomain.com
#
# We will also overwrite /etc/sysconfig/docker (again, if it exists) to configure the daemon.  
# A backup will be created at /etc/sysconfig/docker.unixTimestamp
#
# As per the original author, the MIT License applies to this script
#

set -e
STR=2048
if [ "$#" -gt 0 ]; then
  DOCKER_HOST="$1"
else
  echo " => ERROR: You must specify your wildcard domain as the first argument to this scripts! <="
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root" 
   exit 1
fi

echo " => Using Hostname: $DOCKER_HOST  You MUST connect to docker using this host!"

echo " => Ensuring config directory exists..."
mkdir -p "$HOME/.docker"
cd $HOME/.docker

echo " => Verifying ca.srl"
if [ ! -f "ca.src" ]; then
  echo " => Creating ca.srl"
  echo 01 > ca.srl
fi

echo " => Generating CA key"
openssl genrsa \
  -out ca-key.pem $STR

echo " => Generating CA certificate"
openssl req \
  -new \
  -key ca-key.pem \
  -x509 \
  -days 3650 \
  -nodes \
  -subj "/CN=$HOSTNAME" \
  -out ca.pem

echo " => Generating server key"
openssl genrsa \
  -out server-key.pem $STR

echo " => Generating server CSR"
openssl req \
  -subj "/CN=$DOCKER_HOST" \
  -new \
  -key server-key.pem \
  -out server.csr

echo " => Signing server CSR with CA"
openssl x509 \
  -req \
  -days 3650 \
  -in server.csr \
  -CA ca.pem \
  -CAkey ca-key.pem \
  -out server-cert.pem

echo " => Generating client key"
openssl genrsa \
  -out key.pem $STR

echo " => Generating client CSR"
openssl req \
  -subj "/CN=docker.client" \
  -new \
  -key key.pem \
  -out client.csr

echo " => Creating extended key usage"
echo extendedKeyUsage = clientAuth > extfile.cnf

echo " => Signing client CSR with CA"
openssl x509 \
  -req \
  -days 3650 \
  -in client.csr \
  -CA ca.pem \
  -CAkey ca-key.pem \
  -out cert.pem \
  -extfile extfile.cnf
