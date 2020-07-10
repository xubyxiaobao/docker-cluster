#!/bin/bash
#环境变量设置

export ENV_SHELL_LOAD=true
#==================================
#全局变量

export REGISTRY_HOST=192.168.35.103
export REGISTRY_PORT=5000

#项目运行docker子网
export NETWORK=ddc_network
export SUBNET=172.32.0.0/16
export GATEWAY=172.32.0.1

#支持的服务
export ALL_SERVICES="|zookeeper|kafka|redis|mongodb|nifi|nginx|mysql|"
#支持的命令
export ALL_COMMANDS="|start|stop|"

#每个服务运行时的后缀
export SERVICE_SUFFIX="_cluster"

export IMAGE_BUILD_SCRIPT="build-image.sh"
export POST_HANDLER_SCRIPT="post-handler.sh"
export STACK_CONFIG="docker-stack.yml"

# 容器默认内存大小
export default_container_memory=512m
#===================================
#服务所需的变量
#zookeeper 运行时所需变量
export zookeeper_image="zookeeper:3.6.1"
export zookeeper_nums=3
# zookeeper容器最大可用内存
export zookeeper_container_memory=512m

#kafka运行时所需变量
export kafka_image="wurstmeister/kafka:2.12-2.5.0"
export kafka_nums=3
# kafka容器最大可用内存
export kafka_container_memory=512m


# redis
export redis_image="gridsum/redis:5.0.9"
export redis_nums=6
export redis_password="123456"
export redis_container_memory=2048m
export redis_sentinel_container_memory=512m
# mongo
export mongodb_image="gridsum/mongo:4.2.8"
export mongodb_nums=3
export mongodb_container_memory=7000m
## mongo 初始管理员账号
export mongodb_admin=admin
## mongo 初始管理员密码
export mongodb_password=123456
## 集群初始化失败重试次数(每台节点)
export mongodb_cluster_init_retry=5
## mongodb集群初始化失败再次重试时间隔时间
export mongodb_cluster_init_sleep=5


#nifi
export nifi_image="gridsum/nifi-cluster:1.11.4"
export nifi_nums=5
export nifi_container_memory=4096m
## nifi的初始管理员为admin 密码为 nifi_ldap_admin_password
export nifi_ldap_admin_password="123456"



#nginx
export nginx_image="gridsum/nginx:1.19.0"
export nginx_nums=1


#mysql
export mysql_image="mysql:5.7"
export mysql_nums=1


#===========================================================================
#所有的微服务，包含在这里面的微服务才会启动

export MICRO_SERVER_COMMANDS='spring-web1="--server.port=9081"
spring-web2="--server.port=9082" spring-web3="--server.port=9083"
spring-web4="--server.port=9084" spring-web5="--server.port=9085"'