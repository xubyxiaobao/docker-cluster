#!/bin/bash

dir=$(cd $(dirname $0);pwd);
[ ! ${ENV_SHELL_LOAD} ] && source $dir/../env.sh

# 初始化redis集群
# 依次检查6个redis实例是否启动成功

node_ip_array=("${NODE1_IP}" "${NODE2_IP}" "${NODE3_IP}")
node_port_array=("${redis_master_out_port}" "${redis_slave_out_port}")


function clusterInit(){
    docker run --rm -it --entrypoint redis-cli ${REGISTRY}${redis_image}   --cluster create  \
    ${NODE1_IP}:${redis_master_out_port}  ${NODE2_IP}:${redis_master_out_port} \
    ${NODE3_IP}:${redis_master_out_port}  ${NODE3_IP}:${redis_slave_out_port} \
    ${NODE1_IP}:${redis_slave_out_port} ${NODE2_IP}:${redis_slave_out_port}  --cluster-replicas 1 -a ${redis_password}

    if [ "0" -eq "$?" ]; then
        echo -e  "\033[32mredis cluster初始化成功\033[0m"
        exit 0
    else
        echo -e "\033[33mredis cluster自动初始化失败，请进行手动初始化\033[0m"
        exit 127
    fi
}

#连接每个节点，检测是否可以连接
function checkNodeStatus(){
    for node_ip in ${node_ip_array[@]} ; do
        for node_port in ${node_port_array[@]} ; do
            cluster_statue=false;
            #每台节点的重试次数
            for (( index=0;index<${redis_cluster_init_retry};index++));
            do
                # 检测redis是否启动、是否已经初始化
               result=$(docker run --rm -it --entrypoint redis-cli ${REGISTRY}${redis_image} -h ${node_ip} -p ${node_port} -a ${redis_password} cluster nodes )
                if [ "0" -eq "$?" ]; then
                    echo -e  "IP=${node_ip}:${node_port} redis节点启动成功"
                    cluster_statue=true;
                    break;
                else
                    echo -e "\033[33mIP=${node_ip}:${node_port} redis节点未启动成功，重新检测\033[0m"
                    sleep ${redis_cluster_init_sleep}
                fi
            done
            #检测所有节点是否启动成功
            if  ! $cluster_statue; then
                echo -e  "\033[31m节点${node_ip}:${node_port}启动失败，请查看日志\033[0m"
                exit
            fi
        done
    done
}

#检测redis节点启动状态
checkNodeStatus

#检查 result 内携带的信心，判断是否需要进行初始化操作
for node_ip in ${node_ip_array[@]} ; do
    for node_port in ${node_port_array[@]} ; do
        if [ 0 -eq $(echo $result|grep "${node_ip}:${node_port}"|wc -l) ]; then
            #开始进行初始化
            echo -e  "\033[32m正在进行redis cluster初始化操作，请确认节点分配方案后输入 yes  \033[0m"
            clusterInit
            #初始化完成
            exit 0
        fi
    done
done
echo -e  "\033[32mredis cluster已初始化，不再进行初始化操作\033[0m"
exit 0