#!/bin/bash
# 将在当前目录的 镜像压缩包解压后导入到本地仓库并上传至私服

base_dir=$(cd $(dirname $0);pwd)
source  ./env.sh

domain="${REGISTRY_HOST}:${REGISTRY_PORT}/"

tar_images="${base_dir}/${IMAGES_TAR_NAME}.tar.gz"
if [ ! -f $tar_images ]; then
    echo -e "\033[31m${tar_images} 不存在文件\033[0m"
    exit 127;
fi


echo -e "\033[33m开始解压文件${tar_images}\033[0m"
#解压缩
tar -zxvf $tar_images
echo -e "\033[32m文件解压完成\033[0m"

echo -e "\033[33m开始加载镜像文件\033[0m"
for image in $(ls ${base_dir}/${IMAGES_TAR_NAME})
do
    echo "加载镜像 ${image}"
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




echo -e "\033[33m开始启动docker-registry容器\033[0m"
docker run -d --name registry -p ${REGISTRY_PORT}:5000 \
-v ${REGISTRY_STORAGE}:/var/lib/registry \
--restart=always registry:2
echo -e "\033[32mdocker-registry容器已启动完成\033[0m"


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

echo "私服上的容器总览："
curl -XGET http://${REGISTRY_HOST}:${REGISTRY_PORT}/v2/_catalog

for image in ${image_arr[@]}
do
    image_name=$(echo $image|awk -F':' '{print $1}')
    echo "私服上的${image_name} 镜像列表："
    curl -XGET http://${REGISTRY_HOST}:${REGISTRY_PORT}/v2/$image_name/tags/list
done
