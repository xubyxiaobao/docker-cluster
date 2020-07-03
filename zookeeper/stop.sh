#!/bin/bash


echo -e "\033[32mzookeeper开始下线...\033[0m"
docker stack rm $ZOOKEEPER_CLUSTER_NAME
echo -e "\033[32mzookeeper完成下线\033[0m"

