#!/bin/bash
# docker镜像的版本号
KEYSTORE_PASSWORD=QKZv1hSWAFQYZ+WU1jjF5ank+l4igeOfQRp+OSbkkrs
TRUSTSTORE_PASSWORD=rHkWR1gDNW3R9hgbeRsT3OM3Ue0zwGtQqcFKJD2EXWE
CURR_DIR=$(cd $(dirname $0); pwd)
SUB_NET=ddc-network
# 每个节点的域名
NODE_HOSTS="nifi1.gridsum.com,nifi2.gridsum.com,nifi3.gridsum.com"
CONFIG_DIR="config"
DEFAULT_IMAGE_TAG="gridsum/nifi-cluster:1.11.4"


#1、创建网络
if [ -z $(docker network ls -f name=$SUB_NET -q) ]; then
    docker network create --subnet=172.32.0.0/16 $SUB_NET
    echo "新建Docker子网： $SUB_NET"
else
    echo "使用已存在的Docker子网： $SUB_NET"
fi


#3、生成证书文件夹
rm -rf $CURR_DIR/$CONFIG_DIR/secure  \
&& mkdir -p $CURR_DIR/$CONFIG_DIR/secure  \
&& chmod  777 $CURR_DIR/$CONFIG_DIR/secure
echo "清理$CURR_DIR/$CONFIG_DIR/secure完成"


#2、开始生成证书：
echo "开始生成集群证书..."
echo "证书生成路径：$CURR_DIR/$CONFIG_DIR/secure"
echo "证书域名：$NODE_HOSTS"
echo "证书类型：JKS"
echo "证书keyStorePassword：$KEYSTORE_PASSWORD"
echo "证书trustStorePassword: $TRUSTSTORE_PASSWORD"

#2、生成证书，nifi开启https所必须
docker run --rm --name nifi-tool -it  -v $CURR_DIR/$CONFIG_DIR/secure:/data/  \
--entrypoint /bin/bash apache/nifi:1.11.4 \
/opt/nifi/nifi-toolkit-current/bin/tls-toolkit.sh standalone \
-n "$NODE_HOSTS" -o '/data' -O 'true' \
-C 'cn=admin,dc=gridsum,dc=com' \
-S ${KEYSTORE_PASSWORD} -P ${TRUSTSTORE_PASSWORD} 		


# 检查证书是否生成成功
OLD_IFS="$IFS"
IFS=","
arr=($NODE_HOSTS)
for VAR in ${arr[@]}
do
    if [ ! -d $CURR_DIR/$CONFIG_DIR/secure/$VAR ] ; then
        echo -e "\033[31m证书生成失败：缺少$CURR_DIR/$CONFIG_DIR/secure/$VAR \033[0m" 
        exit 127
    fi
done
IFS="$OLD_IFS"



#3、删除多余文件
##保留 NODE_HOSTS中的jks文件

for VAR in $(ls $CURR_DIR/$CONFIG_DIR/secure)
do
    if [[ "$NODE_HOSTS" =~ .*$VAR.* ]]; then
        #保留jks文件
        for file in $(ls $CURR_DIR/$CONFIG_DIR/secure/$VAR)
        do
            if [[ ! "$file" =~ .*jks$ ]]; then
                echo  "删除文件$CURR_DIR/$CONFIG_DIR/secure/$VAR/$file"
            fi
        done
    else
        echo  "删除文件$CURR_DIR/$CONFIG_DIR/secure/$VAR"
    fi
done


echo "网络、证书准备完成"

flag=true
while [ $flag ]
do
    read -t 3  -p "是否需要构建镜像(y/n,default y):" answer
    answer=${answer:-y}

    if [[ "y" == $answer || "Y" == $answer ]]; then
        break
    elif [[ "n" == $answer || "N" == $answer ]]; then
        echo "退出..."
        exit 0;
    else
        echo "只能填写'y'或'n'"
    fi
done

echo "开始准备镜像，检查构建镜像配置..."

#检查镜像所需文件是否齐全
NEED_FILES="authorizers.xml,bootstrap.conf,bootstrap-notification-services.xml,\
Dockerfile,logback.xml,login-identity-providers.xml,\
nifi.properties,nifi-cluster.sh,state-management.xml";
OLD_IFS="$IFS"
IFS=","
arr=($NEED_FILES)
for VAR in ${arr[@]}
do
    if [ ! -f $CURR_DIR/$CONFIG_DIR/$VAR ]; then
        echo -e "\033[31m缺少配置文件$CURR_DIR/$CONFIG_DIR/$VAR \033[0m" 
        exit 127
    fi
done
IFS="$OLD_IFS"

echo "构建镜像配置检查完成"

read -t 30 -p "请输入镜像标签(default:$DEFAULT_IMAGE_TAG)：" tag
tag=${tag:-"$DEFAULT_IMAGE_TAG"}

command="docker build -t $tag  $CURR_DIR/$CONFIG_DIR/"
exec $command

#4、启动ldap
# docker run -p 389:389 -p 636:636 \
# --name openldap \
# --env LDAP_ORGANISATION="gridsum" \
# --env LDAP_DOMAIN="gridsum.com" \
# --env LDAP_ADMIN_PASSWORD="123456" \
# --network=$SUB_NET -d --rm osixia/openldap:1.4.0

#5、启动ldapadmin
# docker run -it -p 80:80 \
# --name phpldapadmin \
# --env PHPLDAPADMIN_HTTPS=false \
# --env PHPLDAPADMIN_LDAP_HOSTS=openldap \
# --network=$SUB_NET -d --rm osixia/phpldapadmin


#6、启动nifi

# docker run --name nifi-cluster-2 -p 8444:8444 \
# -e NODE_HOST=nifi2.gridsum.com \
# -e NIFI_CLUSTER_NODE_ADDRESS=nifi2.gridsum.com \
# -e HTTPS_PORT=8444 \
# --network=ddc-network --ip=172.32.0.21 	\
# --add-host=nifi1.gridsum.com:172.32.0.20 \
# --add-host=nifi2.gridsum.com:172.32.0.21 \
# --add-host=nifi3.gridsum.com:172.32.0.22 \
# -it --rm  --entrypoint /bin/bash gridsum/nifi-cluster:1.11.4


# docker run --name nifi-cluster-3 -p 8445:8445  \
# -e NODE_HOST=nifi3.gridsum.com \
# -e NIFI_CLUSTER_NODE_ADDRESS=nifi3.gridsum.com \
# -e HTTPS_PORT=8445 \
# --network=ddc-network --ip=172.32.0.22 	\
# --add-host=nifi1.gridsum.com:172.32.0.20 \
# --add-host=nifi2.gridsum.com:172.32.0.21 \
# --add-host=nifi3.gridsum.com:172.32.0.22 \
# -it --rm  --entrypoint /bin/bash gridsum/nifi-cluster:1.11.4


