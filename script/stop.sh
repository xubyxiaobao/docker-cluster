#!/bin/bash

##加载变量
source env.sh
dir=$(cd $(dirname evn.sh);pwd)




echo "停止zookeeper集群..."
docker stack rm $ZOOKEEPER_CLUSTER_NAME
sleep 5
docker stack ps $ZOOKEEPER_CLUSTER_NAME