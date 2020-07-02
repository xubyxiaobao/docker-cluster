#!/bin/bash

dir=$(cd $(dirname $0);pwd);

#生成认证文件mongodb.key
openssl rand -base64 512 > $dir/mongodb.key


# 开始构建 mongodb镜像
docker build -t gridsum/mongo:4.2.8 .


#if [[ 1 < $(docker network ls -f name=$network |wc -l) ]]; then
#	#docker-stack.yml  path
#	docker_stack=$(pwd)/docker-stack.yml
#
#	#启动副本集
#	docker stack deploy -c $docker_stack $serverName
#
#	#副本集初始化
#	docker run --rm -it --network=$network --entrypoint mongo mongo --host mongodb1 --username root --password root --eval 'config={"_id":"rs","members":[{"_id":0,"host":"mongodb1:27017"},{"_id":1,"host":"mongodb2:27017"},{"_id":2,"host":"mongodb3:27017"}]};rs.initiate(config);'
#else
#	echo "不存在ddc-net网络"
#fi





