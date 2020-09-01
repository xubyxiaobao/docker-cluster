#!/bin/bash

dir=$(cd $(dirname $0);pwd);
[ ! ${ENV_SHELL_LOAD} ] && source $dir/../env.sh

insert_sql_template="insert into mqtt_user(username,password,is_superuser,created) values('#username','#password',0,now())"
insert_sqls="";
#生成insert sql
if [ -z "${emqx_users}" ]; then
    echo -e "\033[33m变量emqx_users为空，取默认值 emqx_users=mqttuser:1qaz2wsx\033[0m"
    emqx_users=mqttuser:1qaz2wsx
fi


OLD_IFS="$IFS"
IFS=","
arr=($emqx_users)
IFS="$OLD_IFS"
for userinfo in ${arr[@]}
do
    #
    username=$(echo $userinfo|awk -F':' '{print $1}')
    password=$(echo $userinfo|awk -F':' '{print $2}')
    sql=$(echo $insert_sql_template|sed "s@#username@$username@g"|sed "s@#password@$password@g")';'
    insert_sqls=$insert_sqls"$sql"
done

#插入的sql语句
echo -e "\033[32m生成的sql语句为：$insert_sqls\033[0m"


#替换init.sql中的insert语句
sed -i "s@insert into mqtt_user.*@ @g" $dir/init.sql
echo $insert_sqls >> $dir/init.sql


#执行初始化脚本
docker run -v $dir/init.sql:/opt/init.sql \
--network=${NETWORK} --rm --entrypoint mysql ${REGISTRY}${mysql_image} \
--host=mysql --port=3306 --user=root --password=${mysql_root_passwd}  \
-e "source /opt/init.sql"
