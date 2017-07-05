#/bin/bash
# Switches to the local docker instances and runs a command on the local machine
# Usage: ./local-docker <command> <args>
# Ex: ./local-docker docker-compose up -d

SAVE_DOCKER_HOST=$DOCKER_HOST
SAVE_DOCKER_TLS_VERIFY=$DOCKER_TLS_VERIFY

unset DOCKER_HOST
unset DOCKER_TLS_VERIFY

$1 "${@:2}"

export DOCKER_HOST=$SAVE_DOCKER_HOST 
export DOCKER_TLS_VERIFY=$SAVE_DOCKER_TLS_VERIFY