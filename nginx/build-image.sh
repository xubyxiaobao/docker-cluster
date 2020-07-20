#!/bin/bash

#检查环境变量是否存在，从而判断../env.sh是否需要加载
[ ! ${ENV_SHELL_LOAD} ] && srouce ../env.sh


dir=$(cd $(dirname $0);pwd);

echo "开始构建nginx镜像"
docker build --build-arg REGISTRY=${REGISTRY} -t ${REGISTRY}${nginx_image}  ${dir}/

docker push ${REGISTRY}${nginx_image}
if [ $? -ne 0 ]; then
    echo "构建nginx出错"
    docker rmi -f ${nginx_image}
    exit 127
fi