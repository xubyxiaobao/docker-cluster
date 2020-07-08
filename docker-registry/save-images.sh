#!/bin/bash
# 在能连接外网的机器上将需要的镜像进行打包，之后将压缩文件上传至内网，执行init-registry.sh脚本将镜像注册至私服

base_dir=$(cd $(dirname $0))

source  ./env.sh

mkdir -p ${base_dir}/$IMAGES_TAR_NAME

download_path=${base_dir}/$IMAGES_TAR_NAME

image_arr=($SAVE_IMAGES)
#从远程仓库下载
echo  "开始进行镜像文件生成。。。"
for image in ${image_arr[@]}
do
    if [ -z $(docker images $image -q) ]; then
#        docker pull $image
         echo "开始从远程仓库拉取镜像 $image"
    fi

    file_name=$(echo $image|awk -F'/' '{print $NF}')
    docker save -o "${download_path}/${file_name}.tar" $image
    echo "镜像${image}本地保存已完成"
done

#将镜像文件夹打包
echo "开始将已下载的镜像打包，打包文件名："
tar_name=$(basename $download_path)


tar -czvf "${tar_name}.tar.gz" $download_path

#