#!/bin/bash

echo "开始进行镜像构建：gridsum/redis:5.0.9"

dir=$(cd $(dirname $0);pwd);


# 开始构建 mongodb镜像
docker build -t gridsum/redis:5.0.9 ${dir}/

if [ $? -ne 0 ]; then
    echo -e "\033[31m构建镜像 gridsum/redis:5.0.9 失败\033[0m"
    exit 127
fi



