#!/bin/bash
#环境变量设置


#==================================
#全局变量
export SAVE_IMAGES="mongo:4.2.8-bionic osixia/openldap:1.4.0 redis:5.0.9 nginx:1.19.0 apache/nifi:1.11.4 osixia/phpldapadmin:latest mysql:5.7 registry:2"
export IMAGE_DIR="images"
export REGISTRY_HOST=192.168.35.103:5000/

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
export mongodb_image="gridsum/mongo:4.2.8"
export mongodb_nums=3
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
export nifi_ldap_domain="gridsum.com"
## nifi的初始管理员为admin 密码为 nifi_ldap_admin_password
export nifi_ldap_admin_password="123456"



#nginx
export nginx_image="gridsum/nginx:1.19.0"
export nginx_nums=1


#mysql
export mysql_image="mysql:5.7"
export mysql_nums=1