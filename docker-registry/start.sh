#!/bin/bash
#环境变量设置

docker images --format "{{.Repository}}:{{.Tag}}"

# 导入基础镜像 |zookeeper:3.6.1|redis:5.0.9|apache/nifi:1.11.4|nginx:1.19.0|mysql:5.7.27|mongo:4.2.8-bionic|wurstmeister|kafka:2.12-2.5.0|
docker load

# 启动docker-registry
docker run -d --name registry -p 5000:5000 \
-v /usr/local/gridsum/registry_img:/tmp/registry \
--restart=always registry


