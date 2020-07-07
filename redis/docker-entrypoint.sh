#!/bin/bash

set -e

#配置文件覆盖
##删除 /data/redis.conf  /data/sentinel.conf
rm -rf /data/redis.conf /data/sentinel.conf
cp  /data/redis_template.conf /data/redis.conf
cp  /data/sentinel_template.conf /data/sentinel.conf


function updateConfig(){
    key=$1
    value=$2
    file=$3
    echo "[Configuring]  $file >>> $key = $value  "
        sed -r -i "s@^$key.*@ @g" "$file"
        echo "$key $value" >> "$file"
}



# 1、确定是redis-server还是redis-sentinel
## redis启动时的配置文件路径
config_path="/data/redis.conf"
if [[ $1 == "redis-server" ]]; then
   echo -e "\033[32m 当前运行模式为 redis-server \033[0m"

    if [ ! -z "$BIND_IP" ]; then
        updateConfig "bind" "${BIND_IP}" $config_path
    fi

    if [ ! -z "$SLAVEOF" ]; then
        updateConfig "slaveof" "${SLAVEOF}" $config_path
    fi

    if [ ! -z "$PASSWORD" ]; then
        updateConfig "requirepass" "${PASSWORD}" $config_path
        updateConfig "masterauth" "${PASSWORD}" $config_path
    fi

    if [ ! -z "$PROTECTED_MODE" ]; then
        updateConfig "protected-mode" "${PROTECTED_MODE}" $config_path
    fi

    if [ ! -z "$PORT" ]; then
        updateConfig "port" "${PORT}" $config_path
    fi

else
    ## 如果为哨兵模式，则更改为对应的配置文件路径
    config_path="/data/sentinel.conf";
    echo -e "\033[32m 当前运行模式为 redis-sentinel \033[0m"

    if [ -z "$SENTINEL_NAME" ]; then
        SENTINEL_NAME="mymaster"
    fi
    if [ -z "$SENTINEL_MASTER" ]; then
        echo -e "\033[31m sentinel模式下属性SENTINEL_MASTER必须存在，参考sentinel monitor <master-name> <ip> <redis-port> <quorum> \033[0m"
        exit 127
    fi
    updateConfig "sentinel monitor" "${SENTINEL_NAME} ${SENTINEL_MASTER}" $config_path
    if [ ! -z "$SENTINEL_AUTHPASS" ]; then
        updateConfig "sentinel auth-pass" "${SENTINEL_NAME} ${SENTINEL_AUTHPASS}" $config_path
    fi
    if [ -z "$SENTINEL_DOWN_AFTER" ]; then
        SENTINEL_DOWN_AFTER=30000
    fi
    if [  -z "$SENTINEL_PARALLEL_SYNCS" ]; then
        SENTINEL_PARALLEL_SYNCS=1
    fi
    if [  -z "$SENTINEL_FAILOVER_TIMEOUT" ]; then
        SENTINEL_FAILOVER_TIMEOUT=180000
    fi
    updateConfig "port" "${PORT}" $config_path
    updateConfig "sentinel down-after-milliseconds" "${SENTINEL_NAME} ${SENTINEL_DOWN_AFTER}" $config_path
    updateConfig "sentinel parallel-syncs" "${SENTINEL_NAME} ${SENTINEL_PARALLEL_SYNCS}" $config_path
    updateConfig "sentinel failover-timeout" "${SENTINEL_NAME} ${SENTINEL_FAILOVER_TIMEOUT}" $config_path
fi


##执行命令
echo -e "\033[32m $1 开始启动 \033[0m"
exec $1  $config_path