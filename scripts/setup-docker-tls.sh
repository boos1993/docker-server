#!/bin/bash
# Thanks for the jump-start!:
#   https://gist.github.com/Stono/7e6fed13cfd79598eb15#file-create-docker-tls-sh
#
# This script will help you setup Docker daemon TLS authentication.
# To run it, you pass your fully qualifed domain name
#
# For example:
#    ./setup-docker-tls.sh docker.mydomain.com
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

OPTIONS=" --tlsverify --tlscacert=$HOME/.docker/ca.pem --tlscert=$HOME/.docker/server-cert.pem --tlskey=$HOME/.docker/server-key.pem -H=0.0.0.0:2376"
if [ -d "/etc/systemd/system/" ]; then

  echo " => Configuring /etc/systemd/system/docker.service"
  rm "/etc/systemd/system/docker.service"
  touch "/etc/systemd/system/docker.service"

  sudo sh -c "echo '[Service]
  Environment=\"DOCKER_OPTS=$OPTIONS\"
  ExecStart=/usr/bin/dockerd \$DOCKER_OPTS -H unix:///var/run/docker.sock -H fd://' >> /etc/systemd/system/docker.service"
else
  echo " => WARNING: Systemd installation not detected"
  echo " =>   You will need to configure your docker daemon manually with the following options:"
  echo " =>   $OPTIONS" 
fi

# Restart daemon
systemctl daemon-reload
systemctl restart docker

echo " => Done!"
