#!/bin/bash

#检查环境变量是否存在，从而判断../env.sh是否需要加载
dir=$(cd $(dirname $0);pwd);
[ ! ${ENV_SHELL_LOAD} ] && source $dir/../env.sh

echo "开始构建nginx镜像"
docker build --build-arg REGISTRY=${REGISTRY} --build-arg BASIC_IMAGE=${basic_nginx_image} -t ${REGISTRY}${nginx_image}  ${dir}/

docker push ${REGISTRY}${nginx_image}
if [ $? -ne 0 ]; then
    echo "构建nginx出错"
    docker rmi -f ${nginx_image}
    exit 127
fi