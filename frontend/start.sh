#!/bin/bash

base_dir=$(cd $(dirname $0);pwd)

if [ -d "${jar_file}" ]; then
    echo -e "\033[31m启动包${base_dir}/${1}不存在\033[0m"
    exit 127
fi

export STACK_SERVER=$1
export MICRO_SERVER="gridsum/${STACK_SERVER}"
export MICRO_VERSION=$(date +%Y%m%d%H%M%S)

docker build  --build-arg REGISTRY=${REGISTRY} --build-arg BASIC_IMAGE=${basic_nginx_image}   -t "${REGISTRY}${MICRO_SERVER}:${MICRO_VERSION}"  ${base_dir}/

if [ $? -ne 0 ]; then
    echo "构建失败"
    exit 127
fi

docker push "${REGISTRY}${MICRO_SERVER}:${MICRO_VERSION}"


docker stack deploy -c ${base_dir}/${STACK_CONFIG} ${STACK_SERVER}


unset STACK_SERVER
unset MICRO_SERVER
unset MICRO_VERSION
unset MICRO_COMMAND
