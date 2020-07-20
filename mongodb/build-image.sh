#!/bin/bash

[ ! ${ENV_SHELL_LOAD} ] && srouce ../env.sh

dir=$(cd $(dirname $0);pwd);

#生成认证文件mongodb.key
openssl rand -base64 512 > $dir/mongodb.key

# 开始构建 mongodb镜像
docker build --build-arg REGISTRY=${REGISTRY} -t ${REGISTRY}${mongodb_image} ${dir}/

#推送镜像至私服
docker push ${REGISTRY}${mongodb_image}

if [ $? -ne 0 ]; then
    echo -e "\033[31m构建镜像 ${mongodb_image} 失败\033[0m"
    exit 127
fi



