#!/bin/bash

echo "开始进行后置处理"

initFlag=false;
for (( index=1 ; index < 4 ; index++ ));
do
    if $initFlag; then
        echo "mongodb集群初始化成功！"
        break;
    fi
    for (( i=0 ; i < ${mongodb_cluster_init_retry} ; i++ ));
    do
        echo "初始化mongodb集群...count=$i"
        result=$(docker run --rm -it --network=$NETWORK --entrypoint mongo mongo:4.2.8-bionic \
        --host mongodb${SERVICE_SUFFIX}_mongodb${index} --username ${mongodb_admin} \
        --password ${mongodb_password} \
        --eval 'config={"_id":"rs","members":[{"_id":0,"host":"mongodb1:27017"},
        {"_id":1,"host":"mongodb2:27017"},
        {"_id":2,"host":"mongodb3:27017"}]};
        rs.initiate(config);');

        echo "mongodb集群初始化结果>>>>>>>>>>>>>>>>>"
        echo "$result"

        if [ $(echo $result|grep '"ok" : 1'|wc -l) == 1 ]; then
            initFlag=true
            break
        fi
        if [ $i == $((mongodb_cluster_init_retry-1)) ]; then
            echo "mongo初始化失败"
            exit 127
        fi
        echo "第$((i+1))次集群初始化失败，休眠5秒。。。"
        sleep 5
    done
done

