#!/bin/bash

set -e
# 接受2个参数
# arg1： start/stop  启动、停止服务
# arg2： 具体服务名称/all  如果为空则为all；包括的服务 zookeeper、kafka、redis、mongo、nifi
##加载变量

basedir=$(cd $(dirname $0);pwd)
source ${basedir}/env.sh






## 参数检查
if [ -z "$1" ]; then
     echo -e "\033[31m命令格式错误\033[0m"
     echo -e "用法：\t$(basename $0) command [service] \n\
 \n\tcommand=$(echo "$ALL_COMMANDS"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') \
 \n\tservice=$(echo "$ALL_SERVICES"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g')/all，default=all"
 exit 127;
fi

command=$1
## 检查命令是否在 ALL_COMMAND中
if [[ ! $ALL_COMMANDS = *"|$command|"* ]]; then
    echo -e "\033[31m命令错误，只能是$(echo "$ALL_COMMANDS"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') 中的一个\033[0m"
    exit
fi

server="all";
if [ ! -z "$2" ]; then
    server="$2"
fi

if [[ "$server" != "all" ]] && [[ ! "$ALL_SERVICES" = *"|$server|"*  ]] ; then
    echo -e "\033[31m服务错误，只能是$(echo "$ALL_SERVICES"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') 中的一个\033[0m"
    exit
fi


echo  "开始进行网络检查..."
isCreateNet=false
##检查docker子网是否创建成功
if [ -z $(docker network ls  -f name=$NETWORK -q) ]; then
    #不存在 subnet
    isCreateNet=true
elif [ -z $(docker network ls  -f name=$NETWORK -f driver=overlay -q) ]; then
    #存在subnet网络但不是overlay类型的
    echo -e "\033[31m已存在docker子网${NETWORK},但子网类型不为overlay，请先删除！\033[0m"
    exit 127
fi
if $isCreateNet; then
    #创建网络
    docker network create --attachable=true --driver overlay --subnet=$SUBNET --gateway=$GATEWAY $NETWORK
    if [ $? == 0 ]; then
        echo "${NETWORK}创建成功"
    else
        echo "${NETWORK}创建失败"
        exit 127
    fi
fi
unset isCreateNet
echo -e "\033[32m网络检查完毕\033[0m"





function checkScript(){
    #检查是否存在start.sh脚本
    if [ ! -d $basedir/$1 ]; then
         echo -e "\033[31m文件夹${basedir}/$1 不存在\033[0m"
         exit 127
    fi
    if [ ! -f "$basedir/$1/${2}.sh" ]; then
        echo -e "\033[31m文件夹${basedir}/$1 缺少${2}.sh\033[0m"
        exit 127
    fi
    if [ ! -x "$basedir/$1/${2}.sh" ]; then
        echo -e "\033[31m$basedir/$1/${2}.sh 没有执行权限！\033[0m"
        exit 127
    fi
}






if [ "all" == "$server" ]; then
    echo  "开始加载所有服务执行脚本"
    OLD_IFS="$IFS"
    IFS=","
    arr=($(echo "$ALL_SERVICES"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/,/g'))
    for file in ${arr[@]}
    do
        #检测脚本是否存在
        checkScript $file $command
    done
    for file in ${arr[@]}
    do
        #进行脚本调用
        echo  "exec $basedir/$file/${command}.sh"
        "$basedir/$file/${command}.sh"
    done
else
    echo -e "开始加载单个服务执行脚本"
    checkScript $server $command
    echo "exec $basedir/$server/${command}.sh"
    "$basedir/$server/${command}.sh" $server
fi











#echo "开始启动zookeeper集群：$ZOOKEEPER_CLUSTER_NAME"
#docker stack deploy -c $dir/$ZOOKEEPER_FILE $ZOOKEEPER_CLUSTER_NAME
#checkUP $ZOOKEEPER_CLUSTER_NAME 3


#echo "开始启动kafka集群：$KAFKA_CLUSTER_NAME"
#docker stack deploy -c $dir/$KAFKA_FILE $KAFKA_CLUSTER_NAME
#checkUP $KAFKA_CLUSTER_NAME 3



#echo "开始启动mongoDB集群：$MONGO_CLUSTER_NAME"
#docker stack deploy -c $dir/$MONGO_FILE $MONGO_CLUSTER_NAME
#checkUP $MONGO_CLUSTER_NAME 3
#
#echo "等待30秒..."
#sleep 30
#echo "mongodb 副本集初始化"
#docker run --rm -it --network=$NETWORK --entrypoint mongo \
#gridsum/mongo:4.2.8 --host mongodb1 --username ${MONGO_ADMIN} --password ${MONGO_PASSWD} \
#--eval 'config={"_id":"rs","members":[{"_id":0,"host":"mongodb1:27017"},{"_id":1,"host":"mongodb2:27017"},{"_id":2,"host":"mongodb3:27017"}]};rs.initiate(config);'