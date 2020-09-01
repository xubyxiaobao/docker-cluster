#!/bin/bash

dir=$(cd $(dirname $0);pwd);
[ ! ${ENV_SHELL_LOAD} ] && source $dir/../env.sh


echo -e "\033[33m开始进行镜像构建：${redis_image}\033[0m"


# 开始构建 mongodb镜像
docker build --build-arg REGISTRY=${REGISTRY} --build-arg BASIC_IMAGE=${basic_redis_image} -t ${REGISTRY}${redis_image} ${dir}/

docker push ${REGISTRY}${redis_image}
if [ $? -ne 0 ]; then
    echo -e "\033[31m构建镜像 ${redis_image} 失败\033[0m"
    exit 127
fi



