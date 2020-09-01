#!/bin/bash
set -e

#配置文件覆盖
config_path="/data/redis.conf"
rm -rf $config_path
cp  /data/redis_template.conf $config_path

function updateConfig(){
    key=$1
    value=$2
    file=$3
    echo "[Configuring]  $file >>> $key = $value  "
        sed -r -i "s@^$key.*@ @g" "$file"
        echo "$key $value" >> "$file"
}

echo -e "\033[32m 启动 redis-cluster 节点 \033[0m"

if [ ! -z "$BIND_IP" ]; then
    updateConfig "bind" "${BIND_IP}" $config_path
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

if [ ! -z "$CLUSTER_ENABLED" ]; then
    updateConfig "cluster-enabled" "${CLUSTER_ENABLED}" $config_path
fi

if [ ! -z "$CLUSTER_CONFIG_FILE" ]; then
    updateConfig "cluster-config-file" "${CLUSTER_CONFIG_FILE}" $config_path
fi

if [ ! -z "$CLUSTER_NODE_TIMEOUT" ]; then
    updateConfig "cluster-node-timeout " "${CLUSTER_NODE_TIMEOUT}" $config_path
fi


if [ ! -z "$ANNOUNCE_IP" ]; then
    updateConfig "cluster-announce-ip" "${ANNOUNCE_IP}" $config_path
    updateConfig "replica-announce-ip" "${ANNOUNCE_IP}" $config_path
fi

if [ ! -z "$ANNOUNCE_PORT" ]; then
    updateConfig "cluster-announce-port" "${ANNOUNCE_PORT}" $config_path
    updateConfig "replica-announce-port" "${ANNOUNCE_PORT}" $config_path
fi

if [ ! z "$ANNOUNCE_BUS_PORT" ]; then
    updateConfig "cluster-announce-bus-port" "${ANNOUNCE_BUS_PORT}" $config_path
elif  [ ! -z "$ANNOUNCE_PORT" ]; then
    updateConfig "cluster-announce-bus-port" "1${ANNOUNCE_PORT}" $config_path
elif  [ ! -z "$PORT" ]; then
    updateConfig "cluster-announce-bus-port" "1${PORT}" $config_path
else
    updateConfig "cluster-announce-bus-port" "16379" $config_path
fi


##执行命令
echo -e "\033[32m $1 开始启动 \033[0m"

exec $1 $config_path