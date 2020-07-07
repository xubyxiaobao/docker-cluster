#!/bin/bash

echo "开始进行镜像构建：${mongodb_image}"

dir=$(cd $(dirname $0);pwd);

#生成认证文件mongodb.key
openssl rand -base64 512 > $dir/mongodb.key

# 开始构建 mongodb镜像
docker build -t ${mongodb_image} ${dir}/

if [ $? -ne 0 ]; then
    echo -e "\033[31m构建镜像 ${mongodb_image} 失败\033[0m"
    exit 127
fi



