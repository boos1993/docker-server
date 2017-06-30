#!/bin/bash
# Basic Usage:
#   ./install.sh <non-root user>

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run using sudo" 
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
systemctl start docker

# Setup Docker tls
./create-docker-tls.sh $HOSTNAME

systemctl daemon-reload
systemctl restart docker

# Do not require password re-entry for sudoers
sed -i '/%sudo   ALL=(ALL:ALL) ALL/c\%sudo   ALL=(ALL) NOPASSWD:ALL' /etc/sudoers


# Expire the root password
sudo passwd -l root