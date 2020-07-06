#!/bin/bash

yellowMsg "开始进行镜像构建：${redis_image}"

dir=$(cd $(dirname $0);pwd);

# 开始构建 mongodb镜像
docker build -t ${redis_image} ${dir}/

if [ $? -ne 0 ]; then
    redMsg "构建镜像 ${redis_image} 失败"
    exit 127
fi



