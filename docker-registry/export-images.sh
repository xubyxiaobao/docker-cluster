#!/bin/bash
# 导出当前宿主机上的所有镜像
images=$(docker images --format "{{.Repository}}:{{.Tag}}")

for image in $(docker images --format "{{.Repository}}:{{.Tag}}")
do

    docker save -o "${image}.tar" $image
    echo
done

