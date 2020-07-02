#!/usr/bin/env bash

dir=$(cd $(dirname evn.sh);pwd)

#include_files="evn.sh,start.sh,stop.sh,../redis"
include_files="../redis"
desc_path="root@192.168.33.21:/opt/docker/"
#desc_path="root@192.168.1.181:/opt/docker/"

OLD_IFS="$IFS"
IFS=","
arr=($include_files)
for file in ${arr[@]} ; do
    absolute_path=${dir}/${file}
    scp -r $absolute_path $desc_path
    if [ $? == 0 ]; then
        echo "${absolute_path} upload success!"
    else
        echo "${absolute_path} upload failed!"
        exit 127
    fi
done
IFS="$OLD_IFS"
