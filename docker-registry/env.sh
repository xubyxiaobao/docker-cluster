#!/bin/bash

##需要进行打包的基础镜像，使用空格分隔
export SAVE_IMAGES="mongo:4.0-xenial osixia/openldap:1.4.0 redis:5.0.9 \
nginx:1.19.0 apache/nifi:1.11.4 osixia/phpldapadmin:0.9.0 \
mysql:5.7 registry:2 zookeeper:3.6.1 openjdk:8u252-jdk-buster \
wurstmeister/kafka:2.12-2.5.0 emqx/emqx:v3.2.0 "
## 从docker导出本地镜像压缩后的文件名，会自动拼接tar.gz
export IMAGES_TAR_NAME="images"
## registry的服务器地址
export REGISTRY_HOST=
## 私服在宿主机上暴露的端口
export REGISTRY_PORT=5000
## 私服数据持久化的地址


function argsCheck(){
    need_props=("REGISTRY_HOST REGISTRY_PORT")
    for var in $need_props
    do
        #是否填写私服地址
        if [ -z "${!var}" ]; then
            echo -e "\033[31m配置项${var}为必填项\033[0m"
            exit 127
        fi
    done
}