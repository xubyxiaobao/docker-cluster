#!/bin/bash

##需要进行打包的基础镜像，使用空格分隔
export SAVE_IMAGES="mongo:4.2.8-bionic osixia/openldap:1.4.0 redis:5.0.9 \
nginx:1.19.0 apache/nifi:1.11.4 osixia/phpldapadmin:latest \
mysql:5.7 registry:2 zookeeper:3.6.1 openjdk:8u252-jdk-buster \
wurstmeister/kafka:2.12-2.5.0"
## 从docker导出本地镜像压缩后的文件名，会自动拼接tar.gz
export IMAGES_TAR_NAME="images"
## registry的服务器地址
export REGISTRY_HOST=192.168.35.103
## 私服在宿主机上暴露的端口
export REGISTRY_PORT=5000
## 私服数据持久化的地址
export REGISTRY_STORAGE=/opt/registry-repository

