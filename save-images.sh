#!/bin/bash
# 在能连接外网的机器上将需要的镜像进行打包，之后将压缩文件上传至内网，执行init-registry.sh脚本将镜像注册至私服


source  ./env.sh


mkdir -p $IMAGE_DIR

image_arr=($SAVE_IMAGES)
#从远程仓库下载
for image in ${image_arr[@]}
do
    result=$(docker pull $image)
    echo "pull镜像结果：$result"
    fileName=$(echo $image|awk -F'/' '{print $NF}')
    docker save -o "${IMAGE_DIR}/${fileName}.tar" $image
done

#将镜像文件夹打包

tar -czvf images.tar.gz ${IMAGE_DIR}

#