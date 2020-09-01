#!/bin/bash

dir=$(cd $(dirname $0);pwd);
[ ! ${ENV_SHELL_LOAD} ] && source $dir/../env.sh


function mongoClusterInit(){
    result=$(docker run --rm -it --network=$NETWORK --entrypoint mongo ${REGISTRY}${mongodb_image} \
    --host ${SERVICE_SUFFIX}mongodb_mongodb1 --username ${mongodb_admin} \
    --password ${mongodb_password} \
    --eval 'config={"_id":"rs","members":[{"_id":0,"host":"'${NODE1_IP}':'${mongodb_out_port}'"},
    {"_id":1,"host":"'${NODE2_IP}':'${mongodb_out_port}'"},
    {"_id":2,"host":"'${NODE3_IP}':'${mongodb_out_port}'"}]};
    rs.initiate(config);');

    echo "mongodb集群初始化结果>>>>>>>>>>>>>>>>>"
    echo "$result"
    if [ $(echo $result|grep '"ok" : 1'|wc -l) == 1 ]; then
        exit 0
    fi
    echo "第$1 次集群初始化失败，休眠${mongodb_cluster_init_sleep}秒。。。"
    sleep ${mongodb_cluster_init_sleep}
}
for (( index=1 ; index <= ${mongodb_nums} ; index++ ));
do
        result=$(docker run --rm -it --network=$NETWORK --entrypoint mongo ${REGISTRY}${mongodb_image} \
        --host ${SERVICE_SUFFIX}mongodb_mongodb${index} --username ${mongodb_admin} \
        --password ${mongodb_password} \
        --eval 'rs.status();')
        echo "集群状态检测结果：$result"
        #能否链接至目标服务器  HostNotFound
        if [ $(echo $result|grep -E 'HostNotFound|Connection refused'|wc -l) -ge 1 ]; then
            echo "${SERVICE_SUFFIX}mongodb_mongodb${index} 未启动成功，${mongodb_cluster_init_sleep}秒之后重新连接"
            index=$(($index-1));
            sleep ${mongodb_cluster_init_sleep}
            continue
        fi

        if [ $(echo $result|grep 'HostNotFound'|wc -l) -ge 1 ]; then
            echo "${SERVICE_SUFFIX}mongodb_mongodb${index} 未启动成功，${mongodb_cluster_init_sleep}秒之后重新连接"
            index=$(($index-1));
            sleep ${mongodb_cluster_init_sleep}
            continue
        fi


        echo "${SERVICE_SUFFIX}mongodb_mongodb${index} 启动成功"
        if [ $index -lt $mongodb_nums ]; then
            echo "开始检测${SERVICE_SUFFIX}mongodb_mongodb${index}是否启动成功"
            sleep ${mongodb_cluster_init_sleep}
            continue
        fi
        # 获取集群初始化状态
        if [ $(echo $result|grep '"errmsg" : "no replset config has been received"'|wc -l) -ge 1 ]; then
            for (( index=1 ; index <= ${mongodb_cluster_init_sleep} ; index++ ))
            do
                echo "集群未初始化，开始进行集群初始化，第${index}次"
                mongoClusterInit
            done
        else
            echo -e "\033[32mmongodb已初始化，不再进行初始化 \033[0m"
            exit 0;
        fi
done


#use admin;db.createUser({user:"admin",pwd:"password",roles: [{ role: "root", db: "admin" }]})

echo -e "\033[31mmongodb初始化失败 \033[0m"
exit 127
