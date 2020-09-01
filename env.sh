#!/bin/bash
#环境变量设置

export ENV_SHELL_LOAD=true
#==================================
#全局变量

#私服的ip 端口信息
export REGISTRY_HOST=
export REGISTRY_PORT=5000
export REGISTRY="${REGISTRY_HOST}:${REGISTRY_PORT}/"

#使用docker node ls命令查看hostname列的值
export NODE1_HOSTNAME=
export NODE2_HOSTNAME=
export NODE3_HOSTNAME=

## node的ip
export NODE1_IP=
export NODE2_IP=
export NODE3_IP=

# 不指定服务名称时默认启动的服务及顺序
export ALL_SERVICES="|zookeeper|kafka|redis|mongodb|mysql|nifi|nginx|emqx|"

export NODE1_TAG=manager1
export NODE2_TAG=manager2
export NODE3_TAG=manager3


export CONTAINER_LOG_NUMS=5
export CONTAINER_LOG_SIZE=20m

#项目运行docker子网
export NETWORK=ddc_network
export SUBNET=172.32.0.0/16
export GATEWAY=172.32.0.1

#基础镜像
export basic_zookeeper_image=zookeeper:3.6.1
export basic_mongodb_image=mongo:4.0-xenial
export basic_kafka_image=wurstmeister/kafka:2.12-2.5.0
export basic_emqx_image=emqx/emqx:v3.2.0
export basic_jdk_image=openjdk:8u252-jdk-buster
export basic_mysql_image=mysql:5.7
export basic_nginx_image=nginx:1.19.0
export basic_nifi_image=apache/nifi:1.11.4
export basic_redis_image=redis:5.0.9
export basic_openldap_image=osixia/openldap:1.4.0
export basic_phpldapadmin_image=osixia/phpldapadmin:0.9.0
export basic_registry_image=registry:2


#支持的命令
export ALL_COMMANDS="|start|stop|"
#每个服务运行时的后缀
export SERVICE_SUFFIX="cluster_"
export IMAGE_BUILD_SCRIPT="build-image.sh"
export POST_HANDLER_SCRIPT="post-handler.sh"
export STACK_CONFIG="docker-stack.yml"

# 容器默认内存大小
export default_container_memory=512m
#===================================
#服务所需的变量
#zookeeper 运行时所需变量
export zookeeper_image=$basic_zookeeper_image
export zookeeper_nums=3
# zookeeper容器最大可用内存
export zookeeper_container_memory=512m
export zookeeper_out_port=2181

#kafka运行时所需变量
export kafka_image=$basic_kafka_image
export kafka_nums=3
# kafka容器最大可用内存
export kafka_container_memory=2048m
export kafka_out_port=9094

# redis
export redis_image="gridsum/${basic_redis_image}"
export redis_nums=6
export redis_password="123456"
export redis_container_memory=2048m
export redis_master_out_port=6379
export redis_slave_out_port=6380
## 集群初始化失败重试次数(每台节点)
export redis_cluster_init_retry=3
## redis集群初始化失败再次重试时间隔时间
export redis_cluster_init_sleep=5



# mongo
export mongodb_image="gridsum/${basic_mongodb_image}"
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
## mongodb集群初始化时，初始化语句所需的ip
export mongodb_out_port=27017

#nifi
export nifi_image="gridsum/${basic_nifi_image}"
export nifi_nums=5
export nifi_container_memory=4096m
## nifi的初始管理员为admin 密码为 nifi_ldap_admin_password
export nifi_ldap_admin_password="123456"



#nginx
export nginx_image="gridsum/${basic_nginx_image}"
export nginx_nums=1


#mysql
export mysql_image=$basic_mysql_image
export mysql_nums=1
export mysql_root_passwd=root
export mysql_max_connections=2048


#emqx
export emqx_image=$basic_emqx_image
export emqx_nums=3
export emqx_outer_mqtt_tcp_port=1883
export emqx_outer_dashboard_port=18083
export emqx_outer_tcp_server_port=5369
export emqx_outer_distributed_node_port=6369
export emqx_outer_managent_port=6369
export emqx_mysql_server=mysql:3306
export emqx_mysql_username=root
export emqx_mysql_password=${mysql_root_passwd}
# 连接emqx pub/sub用户的用户名+密码 格式为： user1:password1,user2:password2...
export emqx_users=admin1:password1,admin2:password2

#===========================================================================
#所有的微服务，包含在这里面的微服务才会启动
# 微服务spring-web1的springboot启动参数为 --server.port=9081 ，spring-web2的springboot启动参数为 --server.port=9082
# export MICRO_SERVER_COMMANDS='spring-web1="--server.port=9081"
#spring-web2="--server.port=9082"'
