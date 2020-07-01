#!/bin/bash

##加载变量
source ./evn.sh
dir=$(cd $(dirname evn.sh);pwd)



isCreateNet=false
##检查docker子网是否创建成功
if [ -z $(docker network ls  -f name=$NETWORK -q) ]; then
    #不存在 subnet
    isCreateNet=true
elif [ -z $(docker network ls  -f name=$NETWORK -f driver=overlay -q) ]; then
    #存在subnet网络但不是overlay类型的
    echo -e "\033[31m已存在docker子网${NETWORK},且子网类型不为overlay，请先删除！\033[0m"
    exit 127
fi

if $isCreateNet; then
    #创建网络
    docker network create --driver overlay --subnet=$SUBNET --gateway=$GATEWAY $NETWORK
    if [ $? == 0 ]; then
        echo "${NETWORK}创建成功"
    else
        echo "${NETWORK}创建失败"
        exit 127
    fi
fi

#echo "开始启动zookeeper集群：$ZOOKEEPER_CLUSTER_NAME"
#docker stack deploy -c $dir/$ZOOKEEPER_FILE $ZOOKEEPER_CLUSTER_NAME
#checkUP $ZOOKEEPER_CLUSTER_NAME 3


#echo "开始启动kafka集群：$KAFKA_CLUSTER_NAME"
#docker stack deploy -c $dir/$KAFKA_FILE $KAFKA_CLUSTER_NAME
#checkUP $KAFKA_CLUSTER_NAME 3



echo "开始启动mongoDB集群：$MONGO_CLUSTER_NAME"
docker stack deploy -c $dir/$MONGO_FILE $MONGO_CLUSTER_NAME
checkUP $MONGO_CLUSTER_NAME 3

echo "mongodb 副本集初始化"
docker run --rm -it --network=$NETWORK --entrypoint mongo \
mongo --host mongodb1 --username ${MONGO_ADMIN} --password ${MONGO_PASSWD} \
--eval 'config={"_id":"rs","members":[{"_id":0,"host":"mongodb1:27017"},{"_id":1,"host":"mongodb2:27017"},{"_id":2,"host":"mongodb3:27017"}]};rs.initiate(config);'