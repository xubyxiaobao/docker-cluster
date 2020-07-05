#!/bin/bash

set -e
# 接受2个参数
# arg1： start/stop  启动、停止服务
# arg2： 具体服务名称/all  如果为空则为all；包括的服务 zookeeper、kafka、redis、mongo、nifi
##加载变量

export BASE_DIR=$(cd $(dirname $0);pwd)
#加载变量
source ${BASE_DIR}/env.sh
#加载函数
source ${BASE_DIR}/common.sh


# 参数检测
argsCheck $@

command=$1
isInclude $ALL_COMMANDS $command "命令"

service="all";
if [ ! -z "$2" ]; then
    service="$2"
fi
isInclude $ALL_SERVICES $service "服务"


# 网络检测
networkCheck



# 服务部署

if [ "all" == "$server" ]; then
    echo  "开始加载所有服务执行脚本"
    OLD_IFS="$IFS"
    IFS=","
    arr=($(echo "$ALL_SERVICES"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/,/g'))
    for var in ${arr[@]}
    do
        $command $var
    done
else
    echo -e "开始加载单个服务执行脚本"
       $command $service
fi

