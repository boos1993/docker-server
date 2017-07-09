#!/bin/bash
# Basic Usage:
#   ./install-docker.sh

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

curl -sSL https://get.docker.com | sh

# Configure Docker to start on boot:
systemctl enable docker
systemctl start docker