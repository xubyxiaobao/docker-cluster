#!/usr/bin/env bash

dir=$(cd $(dirname evn.sh);pwd)


exclude_files="|README.md|transFiles.sh|"
#desc_path="root@192.168.33.21:/opt/docker/"
desc_path="root@192.168.1.181:/opt/docker/"

#OLD_IFS="$IFS"
#IFS=","
#arr=($include_files)
#for file in ${arr[@]} ; do
#    absolute_path=${dir}/${file}
#    scp -r $absolute_path $desc_path
#    if [ $? == 0 ]; then
#        echo "${absolute_path} upload success!"
#    else
#        echo "${absolute_path} upload failed!"
#        exit 127
#    fi
#done
#IFS="$OLD_IFS"


for file in $(ls) ; do
    absolute_path=${dir}/${file}
    if [[ ! -z $(echo "$exclude_files" | grep "|$file|" ) ]]; then
        echo  "skip ${absolute_path}"
    else
        scp -r $absolute_path $desc_path
        if [ $? == 0 ]; then
            echo "${absolute_path} upload success!"
        else
            echo "${absolute_path} upload failed!"
            exit 127
        fi
    fi
done
