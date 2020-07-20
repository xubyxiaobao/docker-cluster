#!/bin/bash
# 在能连接外网的机器上将需要的镜像进行打包，之后将压缩文件上传至内网，执行init-registry.sh脚本将镜像注册至私服

base_dir=$(cd $(dirname $0);pwd)

source  ./env.sh


#参数检查
argsCheck

mkdir -p ${base_dir}/$IMAGES_TAR_NAME

download_path=${base_dir}/$IMAGES_TAR_NAME

image_arr=($SAVE_IMAGES)
#从远程仓库下载
for image in ${image_arr[@]}
do
    if [ -z $(docker images $image -q) ]; then
        echo -e "\033[33m开始从远程仓库拉取镜像 $image\033[0m"
        docker pull $image
        if [ $? -ne 0 ]; then
            echo -e "\031[33m镜像${image}拉取失败\033[0m"
            exit127
        fi
        echo -e "\033[32m镜像${image}已拉取完成\033[0m"
    fi

    file_name=$(echo $image|awk -F'/' '{print $NF}')
    echo -e "\033[33m开始生成${image}的镜像文件\033[0m"
    docker save -o "${download_path}/${file_name}.tar" $image
    if [ $? -ne 0 ]; then
        echo -e "\031[31m镜像${image}保存文件失败\033[0m"
        exit127
    fi
    echo -e "\033[32m镜像${image}的文件已生成\033[0m"
done

tar_name=$(basename $download_path)
#将镜像文件夹打包
echo -e "\033[33m开始将已下载的镜像打包，打包文件名：${tar_name}.tar.gz\033[0m"
cd $download_path;
tar -czvf "../${tar_name}.tar.gz" *
echo -e "\033[32m打包完成，打包文件名：$download_path${tar_name}.tar.gz\033[0m"
