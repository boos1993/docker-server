# Installation

This repo contains scripts and instructions for creating a docker remote host that can be accessed securely over TLS. It is intented to be run on a KVM VPS running Ubuntu 16.10.

## Set hostname on VPS Control panel

    hostname <HOSTNAME>

## SSH into the server:

    ssh <USER>@<HOSTNAME>

    git clone https://github.com/boos1993/docker-server.git && cd ./docker-server/scripts/

    sudo chmod +x install.sh && chmod +x create-docker-tls.sh

    sudo ./install.sh <username-goes-here>

    exit

## Copy docker keys to the client

### Unix:  

    mkdir -pv ~/.docker
    scp -r <USER>@<HOSTNAME>:/home/<USER>/docker-keys/{ca,cert,key}.pem ~./docker"

### Windows:  

    mkdir -pv %USERPROFILE%/.docker
    scp -r <USER>@<HOSTNAME>:/home/<USER>/docker-keys/{ca,cert,key}.pem %USERPROFILE%/.docker/"

## Securing the client automatically

### Unix:  

    export DOCKER_HOST=tcp://$HOST:2376 DOCKER_TLS_VERIFY=1

### Windows:  

    setx DOCKER_HOST tcp://<HOSTNAME>:2376
    setx DOCKER_TLS_VERIFY 1

## Securing the client manually

### Unix:  
    
#### Format:

    docker --tlsverify --tlscacert=~/.docker/ca.pem --tlscert=~/.docker/cert.pem --tlskey=~/.docker/key.pem -H=<HOSTNAME>:2376 <COMMAND_TO_RUN>

#### Examples:

    docker --tlsverify --tlscacert=~/.docker/ca.pem --tlscert=~/.docker/cert.pem --tlskey=~/.docker/key.pem -H=<HOSTNAME>:2376 version

    docker-compose --tlsverify --tlscacert=~/.docker/ca.pem --tlscert=~/.docker/cert.pem --tlskey=~/.docker/key.pem -H=<HOSTNAME>:2376  up -d

### Windows:  

#### Format:

    docker --tlsverify --tlscacert=%USERPROFILE%/.docker/ca.pem --tlscert=%USERPROFILE%/.docker/cert.pem --tlskey=%USERPROFILE%/.docker/key.pem -H=<HOSTNAME>:2376 <COMMAND_TO_RUN>

#### Examples:


    docker --tlsverify --tlscacert=%USERPROFILE%/.docker/ca.pem --tlscert=%USERPROFILE%/.docker/cert.pem --tlskey=%USERPROFILE%/.docker/key.pem -H=<HOSTNAME>:2376 version

    docker-compose --tlsverify --tlscacert=%USERPROFILE%/.docker/ca.pem --tlscert=%USERPROFILE%/.docker/cert.pem --tlskey=%USERPROFILE%/.docker/key.pem -H=<HOSTNAME>:2376 up -d
