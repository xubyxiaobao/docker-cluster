#!/bin/bash

old_dir="$dir"
dir=$(cd $(dirname $0);pwd)

[ -f "${BASE_DIR}/common.sh" ] && . "${BASE_DIR}/common.sh"

#镜像不存在是否需要调用脚本构建
if [ $(docker images gridsum/mongo:4.2.8 -q | wc -l) -eq 0 ]; then
    [ -f "${dir}/build-image.sh" ] && . "${dir}/build-image.sh"
fi


file=$dir/docker-stack.yml
#检查是否存在 docker-stack.yml文件
if [ ! -f $file ]; then
    echo -e "\033[31m文件${file}不存在\033[0m"
fi

stackName="${1:-$dir}${CLUSTER_SUFFIX}"
echo  "开始部署${1:-$dir}集群..."

docker stack deploy -c $dir/docker-stack.yml $stackName

checkUP $stackName 3
echo -e "\033[32m${1:-$dir}集群部署完成，服务名称：${stackName}\033[0m"

