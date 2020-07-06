#!/usr/bin/env bash
# Note：
# 1、必须确保目标服务器上存在文件夹 /opt/docker
# 2、必须开启window scp免密传输
#   开启方法：
#


dir=$(cd $(dirname evn.sh);pwd)


exclude_files="|README.md|transFiles.sh|"
#desc_path="root@192.168.33.21:/opt/docker/"
#desc_path="root@192.168.35.101:/opt/docker/"
desc_path="root@192.168.1.181:/opt/docker/"

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
