#!/bin/bash
# Basic Usage:
#   ./install.sh <non-root user>

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ "$#" -gt 0 ]; then
  NONROOTUSER="$1"
else
  echo " => ERROR: You must specify the non-root user as the first arguement to this script <="
  exit 1
fi

# Install misc packages
apt-get update
apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     software-properties-common \
     -y

# Install Docker

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce


# Configure Docker to start on boot:
systemctl enable docker

# Setup Docker tls
./create-docker-tls.sh $HOSTNAME
dockerd --tlsverify --tlscacert=/root/.docker/ca.pem --tlscert=/root/.docker/server-cert.pem --tlskey=/root/.docker/server-key.pem -H=0.0.0.0:2376

# Setup non-root user
if id "$NONROOTUSER" >/dev/null 2>&1; then
        echo "Non-root user already exists"
else
  adduser $NONROOTUSER
  usermod -aG sudo $NONROOTUSER
fi

# Do not require password re-entry for sudoers
sed -i '/%sudo   ALL=(ALL:ALL) ALL/c\%sudo   ALL=(ALL) NOPASSWD:ALL' /etc/sudoers


# Expire the root password
sudo passwd -l root