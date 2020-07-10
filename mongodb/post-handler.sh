#!/bin/bash


function mongoClusterInit(){
    result=$(docker run --rm -it --network=$NETWORK --entrypoint mongo ${REGISTRY}${mongodb_image} \
    --host mongodb${SERVICE_SUFFIX}_mongodb1 --username ${mongodb_admin} \
    --password ${mongodb_password} \
    --eval 'config={"_id":"rs","members":[{"_id":0,"host":"mongodb1:27017"},
    {"_id":1,"host":"mongodb2:27017"},
    {"_id":2,"host":"mongodb3:27017"}]};
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
        --host mongodb${SERVICE_SUFFIX}_mongodb${index} --username ${mongodb_admin} \
        --password ${mongodb_password} \
        --eval 'rs.status();')
        echo "集群状态检测结果："
        echo $result
        #能否链接至目标服务器  HostNotFound
        if [ $(echo $result|grep 'HostNotFound'|wc -l) -ge 1 ]; then
            echo "mongodb${SERVICE_SUFFIX}_mongodb${index} 未启动成功，${mongodb_cluster_init_sleep}秒之后重新连接"
            index=$(($index-1));
            sleep ${mongodb_cluster_init_sleep}
            continue
        fi
        echo "mongodb${SERVICE_SUFFIX}_mongodb${index} 启动成功"
        if [ $index -lt $mongodb_nums ]; then
            echo "开始检测mongodb${SERVICE_SUFFIX}_mongodb${index}是否启动成功"
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
            echo -e  "\033[32mongodb已初始化，不在进行初始化\033[0m"
            exit 0;
        fi
done


#use admin;db.createUser({user:"admin",pwd:"password",roles: [{ role: "root", db: "admin" }]})

echo -e "\033[31mmongodb初始化失败\033[0m"
exit 127

