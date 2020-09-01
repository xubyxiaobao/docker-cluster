#!/bin/bash

dir=$(cd $(dirname $0);pwd);


for file in $(ls /mongo_script); do
    mongo --host "${MONGO_URL}"  < /mongo_script/$file
    if [ "0" -eq "$?" ]; then
        echo -e "\033[32m脚本${file}执行成功\033[0m"
    else
        echo -e "\033[31m脚本${file}执行失败\033[0m"
    fi
done