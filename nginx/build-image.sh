#!/bin/bash

echo "开始构建nginx镜像"
docker build -t gridsum/nginx:1.19.0  .
if [ $? -ne 0 ]; then
    echo "构建nginx出错"
    docker rmi -f gridsum/nginx:1.19.0
    exit 127
fi