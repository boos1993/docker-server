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

## Add scripts to run local docker instead of remote

    You just configured your local machine to default to communicating with the remote server but you still need an easy way to access your local docker CLI. This can be accomplished with the aid of a simple script and some aliases. All it does is unset (and save) the environment variables with the configuration for the remote docker host, runs the docker cli command and then exports the environment variables so that they are back to normal. The result is that you can interact with your local docker CLI but just prepending an `l` to the beginning of the command.

        mkdir -pv ~/.docker/scripts
        curl -o ~/.docker/scripts/local-docker.sh https://raw.githubusercontent.com/boos1993/docker-server/master/scripts/local-docker.sh
        chmod +x ~/.docker/scripts/local-docker.sh

        echo "alias ldocker='~/.docker/scripts/local-docker.sh docker'" >> ~/.bash_aliases && source ~/.bash_aliases
        echo "alias ldocker-compose='~/.docker/scripts/local-docker.sh docker-compose'" >> ~/.bash_aliases && source ~/.bash_aliases
        echo "alias ldockerd='~/.docker/scripts/local-docker.sh dockerd'" >> ~/.bash_aliases && source ~/.bash_aliases
        echo "alias ldocker-machine='~/.docker/scripts/local-docker.sh docker-machine'" >> ~/.bash_aliases && source ~/.bash_aliases

## Setting up remote management using [Portainer](https://github.com/portainer/portainer)

Run this command on your local machine after setting up TLS. You can then configure the console at `http://<HOSTNAME>:9000`

    docker run --name=portainer -d -p 9000:9000 portainer/portainer

## Setting up Docker [Swarm](https://docs.docker.com/engine/swarm/)

Docker swarm is clustering system that allows you to run your docker apps across multiple hosts.

### Create a new cluster

Run this command ond your local machine after setting up TLS

    docker swarm init --advertise-addr <MANAGER-IP>

Save the command that the console outputs and use that to connect additional workers to the swarm

### Setting up a Swarm Visualizer

SSH into the docker host and run this command to setup a swarm visualizer. (I would be hesitant to run this outside of a firewall...)

    sudo docker run -it --name=swarm-visualizer -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer

## Viewing Usage Statistics

To better manage system resources, you can view the CPU and Memory usuage statistics of a docker host using the following command

    docker stats --all --format "table {{.ID}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

## Wait, what about my data?

In order to keep track of your data that you need to persist, it is good practice to use named volumes for any data that you need backed up. This will ensure that you can easily find the data you need by the volume name but the data is still only available on the docker host machine. You need to employ a backup strategy to get that data copied to another location in case something happens to the docker host.  

### Backing up at the volume level

You can run the command below to configure dockup automated (nightly at midnighty) backups to S3. An example environment file is included in this repo.

    docker run --rm --env-file ./env/dockup.env --volumes-from mysql --name dockup wetransform/dockup:latest

You can also find detailed instructions on Docker Hub for [dockup](https://hub.docker.com/r/wetransform/dockup/)

### Backing up at the file level

If you don't want to back up the entire volume, you can instead opt for a file level backup tool. There are tons that you can choose from  but a few notable ones are listed below.

* [fwbackups](http://www.diffingo.com/oss/fwbackups)
* [rsync](https://wiki.archlinux.org/index.php/rsync)
* [Bacula](bacula.org)
* [Backup](https://github.com/backup/backup)
* *or just Google it!*


