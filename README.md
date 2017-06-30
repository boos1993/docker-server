# Installation

This repo contains scripts and instructions for creating a docker remote host that can be accessed securely over TLS. It is intented to be run on a KVM VPS running Ubuntu 16.10.

These commands will need to be run from a bash command line on either a unix machine or under cygwin/git-bash/bash-for-windows on a windows machine.

## SSH into the server as a NON-ROOT user with sudo permissions:

    ssh <USER>@<HOSTNAME>

    hostname <HOSTNAME>

    git clone https://github.com/boos1993/docker-server.git && cd ./docker-server/scripts/

    sudo chmod +x install.sh && chmod +x create-docker-tls.sh

    sudo ./install.sh

    exit

## Copy docker keys to the client

### Unix:  

    mkdir -pv ~/.docker
    scp -r <USER>@<HOSTNAME>:/home/<USER>/.docker/{ca,cert,key}.pem ~/.docker

## Securing the client automatically

    export DOCKER_HOST=tcp://<HOSTNAME>:2376
    export DOCKER_TLS_VERIFY=1

## Securing the client manually

### Unix:  
    
#### Format:

    docker --tlsverify --tlscacert=~/.docker/ca.pem --tlscert=~/.docker/cert.pem --tlskey=~/.docker/key.pem -H=<HOSTNAME>:2376 <COMMAND_TO_RUN>

#### Examples:

    docker --tlsverify --tlscacert=~/.docker/ca.pem --tlscert=~/.docker/cert.pem --tlskey=~/.docker/key.pem -H=<HOSTNAME>:2376 version

    docker-compose --tlsverify --tlscacert=~/.docker/ca.pem --tlscert=~/.docker/cert.pem --tlskey=~/.docker/key.pem -H=<HOSTNAME>:2376  up -d

### Windows:  

These commands can be natively run on a windows machine.

#### Format:

    docker --tlsverify --tlscacert=%USERPROFILE%/.docker/ca.pem --tlscert=%USERPROFILE%/.docker/cert.pem --tlskey=%USERPROFILE%/.docker/key.pem -H=<HOSTNAME>:2376 <COMMAND_TO_RUN>

#### Examples:


    docker --tlsverify --tlscacert=%USERPROFILE%/.docker/ca.pem --tlscert=%USERPROFILE%/.docker/cert.pem --tlskey=%USERPROFILE%/.docker/key.pem -H=<HOSTNAME>:2376 version

    docker-compose --tlsverify --tlscacert=%USERPROFILE%/.docker/ca.pem --tlscert=%USERPROFILE%/.docker/cert.pem --tlskey=%USERPROFILE%/.docker/key.pem -H=<HOSTNAME>:2376 up -d
