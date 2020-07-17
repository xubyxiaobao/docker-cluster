#!/bin/bash

base_dir=$(cd $(dirname $0);pwd)

[ -f ${base_dir}/../env.sh ] && [ -z "$ENV_SHELL_LOAD" ] && source ${base_dir}/../env.sh

export MICRO_SERVER=$1

docker stack rm ${MICRO_SERVER}

