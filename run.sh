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
isInclude $ALL_SERVICES"all|" $service "服务"


# 网络检测
networkCheck






# service
function start(){
    service_name=$1;
    image_name="${service_name}_image"
    number_name="${service_name}_nums"

    docker_image="${!image_name}"
    service_number=${!number_name}


    if [ -z "$docker_image" ]; then
        redMsg "服务${service_name}的镜像版本 ${image_name} 未进行设置"
        exit 127
    fi

    if [ ! "${service_number}" >0 ]; then
        redMsg "服务数量参数 ${number_name} 未设置"
        exit 127
    fi
    echo "arr= $arr"
    echo "var= $var"
    result=$(docker images )
    echo "arr= $arr"
    echo "var= $var"

    #镜像构建
#    if [  -z  ]; then
#        [ -f "${BASE_DIR}/${service_name}/${IMAGE_BUILD_SCRIPT}" ] && /bin/bash "${BASE_DIR}/${service_name}/${IMAGE_BUILD_SCRIPT}"
#    fi
    stack_name="${service_name}${SERVICE_SUFFIX}"
    yellowMsg  "开始部署${stack_name}服务..."
#    docker stack deploy -c ${BASE_DIR}/${service_name}/${STACK_CONFIG} ${stack_name}
#    checkUP ${stack_name} ${service_number}
    greenMsg "${service_name}服务部署完成，服务名称：${stack_name}"

    [ -f "${BASE_DIR}/${service_name}/${POST_HANDLER_SCRIPT}" ] && "${BASE_DIR}/${service_name}/${POST_HANDLER_SCRIPT}"
}


# 服务部署

if [ "all" == "$service" ]; then
    echo  "开始加载所有服务执行脚本"
    OLD_IFS="$IFS"
    IFS=","
#    arr=($(echo "$ALL_SERVICES"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/,/g'))
    arr=("zookeeper,kafka,mongo,redis")
    for(( i=0;i<${#arr[@]};i++))
    do
    　　echo ${array[i]}
    done


        echo "load service:$var"
        $command $var

else
    echo -e "开始加载单个服务执行脚本"
       $command $service
fi

