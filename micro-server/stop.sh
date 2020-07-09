#!/bin/bash

base_dir=$(cd $(dirname $0);pwd)
jar_file="${base_dir}/${1}.jar"
[ -f ${base_dir}/../env.sh ] && [ -z "$ENV_SHELL_LOAD" ] && source ${base_dir}/../env.sh

if [ -d "${jar_file}" ]; then
    echo -e "\033[31m启动包${base_dir}/${1}不存在\033[0m"
    exit 127
fi


export MICRO_SERVER=$1

docker stack rm ${MICRO_SERVER}

