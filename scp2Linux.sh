#!/usr/bin/env bash
# Note：
# 1、必须确保目标服务器上存在文件夹 /opt/docker
# 2、必须开启window scp免密传输
dir=$(cd $(dirname evn.sh);pwd)

function scpInclude(){
    arr=($(echo $include_files | sed 's\|\ \g'))
    for var in ${arr[@]}
    do
        absolute_path=${dir}/${var}
        scp -r $absolute_path $desc_path
        if [ $? == 0 ]; then
            echo "${absolute_path} upload success!"
        else
            echo "${absolute_path} upload failed!"
            exit 127
        fi
    done
}

function scpExclude(){
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
}


#exclude_files="|README.md|scp2Linux.sh|docker-registry|frontend|init-data|"
include_files="|zookeeper|"
#desc_path="root@192.168.33.21:/opt/docker/"
#desc_path="root@192.168.35.101:/opt/docker/"
desc_path="root@192.168.35.103:/opt/docker/"
#desc_path="root@192.168.1.181:/opt/docker/"

if [ -n "${exclude_files}" ]; then
    scpExclude
fi

if [ -n "${include_files}" ]; then
    echo "scpInclude=$include_files"
    scpInclude
fi
