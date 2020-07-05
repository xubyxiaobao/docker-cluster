#!/bin/bash
#环境变量设置


#==================================
#全局变量
export ENV_LOADED=loaded

#项目运行docker子网
export NETWORK=ddc_network
export SUBNET=172.32.0.0/16
export GATEWAY=172.32.0.1

#支持的服务
export ALL_SERVICES="|zookeeper|kafka|redis|mongo|nifi|nginx|"
#支持的命令
export ALL_COMMANDS="|start|stop|"

#每个服务运行时的后缀
export SERVICE_SUFFIX="_cluster"

export IMAGE_BUILD_SCRIPT="build-image.sh"
export POST_HANDLER_SCRIPT="post-handler.sh"
export STACK_CONFIG="docker-stack.yml"
#===================================
#服务所需的变量
#zookeeper 运行时所需变量
export zookeeper_image="zookeeper:3.6.1"
export zookeeper_nums=3

#kafka运行时所需变量
export kafka_image="wurstmeister/kafka:2.12-2.5.0"
export kafka_nums=3

# redis
export redis_image="gridsum/redis:5.0.9"
export redis_nums=6
export redis_password="123456"

# mongo
export mongo_image="gridsum/mongo:4.2.8"
export mongo_nums=3
export mongo_admin=admin
export mongo_password=123456
export mongo_cluster_init_retry=5


#nifi
export nifi_image="gridsum/nifi-cluster:1.11.4"

#nginx
export nginx_image="gridsum/nginx:1.19.0"