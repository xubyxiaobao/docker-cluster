#!/bin/bash

dir=$(cd $(dirname $0);pwd);

echo "开始构建nginx镜像"
docker build -t ${REGISTRY_HOST}${nginx_image}  ${dir}/

docker push ${REGISTRY_HOST}${nginx_image}
if [ $? -ne 0 ]; then
    echo "构建nginx出错"
    docker rmi -f ${nginx_image}
    exit 127
fi