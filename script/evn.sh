#!/bin/bash
#环境变量设置

#项目运行docker子网
NETWORK=ddc_network
SUBNET=172.32.0.0/16
GATEWAY=172.32.0.1

ZOOKEEPER_FILE="zookeeper/docker-stack.yml"
ZOOKEEPER_CLUSTER_NAME="zookeeper_cluster"

KAFKA_FILE="kafka/docker-stack.yml"
KAFKA_CLUSTER_NAME="kafka_cluster"

MONGO_FILE="mongo/docker-stack.yml"
MONGO_CLUSTER_NAME="mongo_cluster"

#mogodb副本集初始化账号
export MONGO_ADMIN=root
export MONGO_PASSWD=root


function checkUP(){
    stack_name=$1
    service_num=$2
    while true; do
        if [ $service_num == $(docker stack ps -f "desired-state=running" -q  $stack_name |wc -l) ]; then
            echo "${stack_name} 启动成功"
            break;
        else
            docker stack ps $stack_name
        fi
        sleep 5
    done
}