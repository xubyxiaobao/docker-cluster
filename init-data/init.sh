#!/bin/bash

dir=$(cd $(dirname $0);pwd);
[ ! ${ENV_SHELL_LOAD} ] && source $dir/../env.sh

script="all";
if [ ! -z "$1" ]; then
    script="$1"
fi

subdir="mysql"
if [[ "all" == "$script" || "$subdir" == "$script" ]]; then

    #mysql
    for file in $(ls $dir/$subdir); do

        file_path=$dir/$subdir/$file

        docker run -v $file_path:/opt/$file --network=${NETWORK} --rm \
        --entrypoint mysql ${REGISTRY}${mysql_image} --host=mysql --port=3306 \
        --user=root --password=${mysql_root_passwd}  -e "source /opt/$file"

        if [ "0" -eq "$?" ]; then
            echo -e "\033[32m脚本${dir}/${file}执行成功\033[0m"
        else
            echo -e "\033[31m脚本${dir}/${file}执行失败\033[0m"
        fi
    done
fi

subdir="mongodb"
if [[ "all" == "$script" || "$subdir" == "$script" ]]; then
    #mongodb://root:i!^ugOnDsRkEI!!ceuYtZ94wci*4nC*l@10.201.82.161:27019,10.201.81.64:27019,10.201.83.46:27019
    mongodb_url="mongodb://${mongodb_admin}:${mongodb_password}@${NODE1_IP}:${mongodb_out_port},${NODE2_IP}:${mongodb_out_port},${NODE3_IP}:${mongodb_out_port}/?replicaSet=rs"

    docker run -v $dir/$subdir/:/mongo_script/  -v $dir/mongo.sh:/opt/mongo.sh --rm  \
    -e MONGO_URL="${mongodb_url}"  --entrypoint /bin/bash ${REGISTRY}${mongodb_image} /opt/mongo.sh
fi