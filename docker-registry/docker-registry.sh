#!/bin/bash
all_commands="|list|tags|delete|"
source ./env.sh

if [ $# -eq 0 ]; then
    echo -e "\033[31m格式错误： command [iamge] \033[0m"
    echo -e "\033[31mcommand=$(echo "$all_commands"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') \033[0m"
    exit 127
fi

if [[ ! $all_commands = *"|$1|"* ]]; then
    echo -e "\033[31m命令错误，只能是$(echo "$all_commands"| awk '{print substr($0,2,length($0)-2)}'|sed 's/|/\//g') 中的一个 \033[0m"
    exit
fi


command=$1
image=$2
echo "command=$command"
echo "image=$image"


#列出所有镜像
# response=$(curl -XGET http://192.168.35.103:5000/v2/_catalog)
function list(){
    response=$(curl -XGET http://${REGISTRY_HOST}:${REGISTRY_PORT}/v2/_catalog)
    echo "${REGISTRY_HOST}:${REGISTRY_PORT} 注册中心镜像列表"
    echo  ${response} | jq
}


#curl -XGET http://192.168.35.103:5000/v2/redis/tags/list
function tags(){
    if [ -z "$image" ]; then
        echo -e "\033[31m缺少镜像名称 \033[0m"
        exit 127
    fi
   response=$(curl -XGET http://${REGISTRY_HOST}:${REGISTRY_PORT}/v2/$image/tags/list)
   echo "${REGISTRY_HOST}:${REGISTRY_PORT}/${image}镜像标签列表"
   echo $response|jq
}


# curl --header "Accept:application/vnd.docker.distribution.manifest.v2+json" -I -XGET http://192.168.35.103:5000/v2/redis/manifests/5.0.9
function delete(){
    if [ -z "$image" ]; then
        echo -e "\033[31m缺少镜像名称 \033[0m"
        exit 127
    fi
    response=$(curl -XGET http://${REGISTRY_HOST}:${REGISTRY_PORT}/v2/$image/tags/list)

    for tag in $(echo $response | jq .tags | sed -r 's/\[|]|,|"/ /g')
    do
        digest=$(curl --header "Accept:application/vnd.docker.distribution.manifest.v2+json" \
        -I -XGET http://${REGISTRY_HOST}:${REGISTRY_PORT}/v2/$image/manifests/$tag | \
        grep 'Etag' | awk -F: '{print substr($NF,1,length($NF)-2)}')
        echo "digest=$digest"
        curl -I -XDELETE http://${REGISTRY_HOST}:${REGISTRY_PORT}/v2/$image/manifests/$digest
    done
}

$command $image