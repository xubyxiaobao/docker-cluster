#!/bin/bash

if [ -z "$1" ]; then
    echo -e "\033[31m必须输入启动包名\033[0m"
    exit   127
fi

base_dir=$(cd $(dirname $0);pwd)
jar_file="${base_dir}/${1}.jar"
[ -f ${base_dir}/../env.sh ] && [ -z "$ENV_SHELL_LOAD" ] && source ${base_dir}/../env.sh

if [ -d "${jar_file}" ]; then
    echo -e "\033[31m启动包${base_dir}/${1}不存在\033[0m"
    exit 127
fi


export MICRO_SERVER=$1
export MICRO_VERSION=$(date +%Y%m%d%H%M%S)

docker build --build-arg package=$(basename $jar_file)  -t "${REGISTRY}${MICRO_SERVER}:${MICRO_VERSION}"  ${base_dir}/

if [ $? -ne 0 ]; then
    echo "构建失败"
    exit 127
fi

docker push "${REGISTRY}${MICRO_SERVER}:${MICRO_VERSION}"

#获取对应command
arr=($MICRO_SERVER_COMMANDS)
for var in ${arr[@]}
do
    server_name=$(echo $var| cut -d= -f1)
    if [ "$server_name" == "$MICRO_SERVER" ]; then
        #去除左右两端的双引号
        export MICRO_COMMAND=$(echo ${var#*=}|awk '{print substr($0,2,length($0)-2)}')
        break
    fi
done



docker stack deploy -c ${base_dir}/${STACK_CONFIG} ${MICRO_SERVER}


unset MICRO_SERVER
unset MICRO_VERSION
unset MICRO_COMMAND
