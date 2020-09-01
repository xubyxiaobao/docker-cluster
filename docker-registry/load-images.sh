#!/bin/bash
# 将在当前目录的 镜像压缩包解压后导入到本地仓库并上传至私服

base_dir=$(cd $(dirname $0);pwd)
source  ./env.sh

argsCheck


domain="${REGISTRY_HOST}:${REGISTRY_PORT}/"

tar_images="${base_dir}/${IMAGES_TAR_NAME}.tar.gz"
if [ ! -f $tar_images ]; then
    echo -e "\033[31m${tar_images} 不存在文件\033[0m"
    exit 127;
fi


echo -e "\033[33m开始解压文件${tar_images}\033[0m"
#解压缩
mkdir -p ${base_dir}/${IMAGES_TAR_NAME}
tar -zxvf $tar_images -C ${base_dir}/${IMAGES_TAR_NAME}
echo -e "\033[32m文件解压完成\033[0m"


echo -e "\033[33m开始加载镜像文件\033[0m"
for image in $(ls ${base_dir}/${IMAGES_TAR_NAME})
do
    echo "加载镜像文件 ${image}"
    docker load -i ${base_dir}/${IMAGES_TAR_NAME}/${image}
done
echo -e "\033[32m镜像文件加载完成\033[0m"



echo -e "\033[33m开始对镜像进行重新打标\033[0m"
image_arr=($SAVE_IMAGES)
for image in ${image_arr[@]}
do
    docker tag  ${image} "${domain}${image}"
    if [ $? -ne 0 ]; then
        echo -e  "\033[31m镜像${image}重新打标失败\033[0m"
        exit 127
    fi
done
echo -e "\033[32m打标已完成\033[0m"

registry_volume="docker-registry-data-volumes"
#检测卷 docker-registry-data-volume 是否创建
if [ $(docker volume ls --filter "name=$registry_volume" --format {{.Name}}|wc -l) -eq 0 ]; then
    #创建卷
    docker volume create $registry_volume
fi



echo -e "\033[33m开始启动docker-registry容器\033[0m"
docker run -d --name registry -p ${REGISTRY_PORT}:5000 \
-v ${registry_volume}:/var/lib/registry \
--restart=always registry:2
sleep 3
echo -e "\033[32mdocker-registry容器已启动\033[0m"


echo -e "\033[33m开始进行镜像推送\033[0m"
for image in ${image_arr[@]}
do
    docker push ${domain}${image}
    if [ $? -ne 0 ]; then
        echo -e  "\033[31m镜像${domain}${image}推送失败\033[0m"
        exit 127
    fi
done

echo -e "\033[32m镜像已推送至私服\033[0m"


# 删除所有本地镜像(registry除外)
#echo -e "\033[33m开始删除多余镜像\033[0m"
#for var in $(docker images --format "{{.Repository}}:{{.Tag}}")
#do
#    if [ $(echo $var|grep "registry"|wc -l) -eq 0 ]; then
#        docker rmi $var
#    fi
#done
#
#echo -e "\033[32m多余镜像删除完毕\033[0m"