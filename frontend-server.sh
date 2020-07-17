#!/bin/bash

base_dir=$(cd $(dirname $0);pwd)

#加载变量
source ${base_dir}/env.sh
#加载函数
source ${base_dir}/common.sh


function argsCheck(){
    ## 参数个数检查
    if [ $# -eq 0 ]; then
         echo -e "\033[31m命令格式错误\033[0m"
         echo -e "用法：\t$(basename $0) command [serviceName] \n\
     \n\tcommand=$(echo "$ALL_COMMANDS"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') "
     exit 127;
    fi
}

argsCheck $@



function isInclude(){
    collection=$1
    element=$2
    name=$3
    if [[ ! $collection = *"|$element|"* ]]; then
        redMsg "${name}错误，只能是$(echo "$collection"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') 中的一个"
        exit
    fi
}

command=$1
isInclude $ALL_COMMANDS $command "命令"


## 服务部署



echo -e "开始执行脚本"
/bin/bash ${base_dir}/frontend/${command}.sh "frontend"
