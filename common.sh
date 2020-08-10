#!/bin/bash

function redMsg(){
    echo -e "\033[31m$@\033[0m"
}

function greenMsg(){
    echo -e "\033[32m$@\033[0m"
}

function yellowMsg(){
    echo -e "\033[33m$@\033[0m"
}


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

function argsCheck(){
    ## 参数个数检查
    if [ $# -eq 0 ]; then
         echo -e "\033[31m命令格式错误\033[0m"
         echo -e "用法：\t$(basename $0) command [service] \n\
     \n\tcommand=$(echo "$ALL_COMMANDS"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') \
     \n\tservice=$(echo "$ALL_SERVICES"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g')/all，default=all"
     exit 127;
    fi
}

function isInclude(){
    collection=$1
    element=$2
    name=$3
    if [[ ! $collection = *"|$element|"* ]]; then
        redMsg "${name}错误，只能是$(echo "$collection"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') 中的一个"
        exit
    fi
}

function networkCheck(){
    echo  "检查是否创建docker子网${NETWORK}"
    is_created=false;
    ##检查docker子网是否创建成功
    if [ -z $(docker network ls  -f name=$NETWORK -q) ]; then
        #不存在 subnet
        is_created=true
    elif [ -z $(docker network ls  -f name=$NETWORK -f driver=overlay -q) ]; then
        #存在subnet网络但不是overlay类型的
        redMsg "已存在docker子网${NETWORK},但子网类型不为overlay，请先删除"
        exit 127
    fi

    if $is_created; then
        #创建网络
        docker network create --attachable=true --driver overlay --subnet=$SUBNET --gateway=$GATEWAY $NETWORK
        if [ $? == 0 ]; then
            greenMsg "${NETWORK}创建成功"
        else
            redMsg "${NETWORK}创建失败"
            exit 127
        fi
    fi

    greenMsg "网络检查完毕"
}



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
    if [ -z "${service_number}" ]; then
        redMsg "服务数量参数 ${number_name} 未设置"
        exit 127
    fi
    #如果是自定义镜像则每次都需要构建

    if [  -z "$(docker images ${REGISTRY}${docker_image}  -q )" ]; then
        [ -f "${BASE_DIR}/${service_name}/${IMAGE_BUILD_SCRIPT}" ] && /bin/bash "${BASE_DIR}/${service_name}/${IMAGE_BUILD_SCRIPT}"
    fi

    stack_name="${service_name}${SERVICE_SUFFIX}"
    yellowMsg  "开始部署${stack_name}服务..."
    docker stack deploy -c ${BASE_DIR}/${service_name}/${STACK_CONFIG} ${stack_name}
    checkUP ${stack_name} ${service_number}
    [ -f "${BASE_DIR}/${service_name}/${POST_HANDLER_SCRIPT}" ] && /bin/bash "${BASE_DIR}/${service_name}/${POST_HANDLER_SCRIPT}"
    greenMsg "${service_name}服务部署完成，服务名称：${stack_name}"
}


function stop(){
    service_name=$1;
    stack_name="${service_name}${SERVICE_SUFFIX}"
    yellowMsg  "开始停止${service_name}服务..."
    docker stack rm ${stack_name}
    greenMsg  "${service_name}已停止"
}

#检查环境变量是否齐全
function baseArgsCheck(){
    need_props=("REGISTRY_HOST REGISTRY_PORT NODE1_HOSTNAME NODE2_HOSTNAME NODE3_HOSTNAME NODE1_IP NODE2_IP NODE3_IP")

    for var in $need_props
    do
        if [ -z "${!var}" ]; then
            redMsg "配置项${var}为必填项"
            exit 127
        fi
    done
}


function baseNodeTag(){
    yellowMsg "正在进行节点标记检测"
    for var in $(env)
    do
        env_var=$(echo "$var" | cut -d= -f1)

        if [[ "$env_var" =~ ^NODE[0-9]_HOSTNAME$ ]]; then
            #swarm中是否存在$var 节点
            if [ -n "$(docker node ls -qf name=${!env_var})" ]; then
                #检测节点是否在线
                if [ $(docker node inspect --format={{.Status.State}} ${!env_var}) != "ready" ]; then
                    redMsg "${!env_var}节点不处于ready状态，无法部署服务"
                    exit  127
                fi
                tag="$(echo $env_var|cut -d_ -f1)_TAG"
                #确保该节点已打标
                if [ -z $(docker node inspect --format={{.Spec.Labels}} ${!env_var}|grep "nodename:${!tag}") ]; then
                    #进行打标操作
                    docker node update --label-add nodename=${!tag} ${!env_var}
                    greenMsg "${!env_var}已成功标记为${!tag}"
                fi
            else
                redMsg "swarm中不存在节点 ${!env_var}！"
                exit 127
            fi
        fi
    done
    greenMsg "节点标记检测完毕"
}
