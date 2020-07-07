#!/bin/bash
# 获取images

source ./env.sh

tar -zxvf ${IMAGE_DIR}/images.tar.gz ${IMAGE_DIR}

#加载镜像
for image in ${image_arr[@]}
do
    docker load -i ${IMAGE_DIR}/$image
done


#打标签
docker tag xx   image

#推送私服
douker push