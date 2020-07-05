#!/bin/bash
# docker镜像的版本号
KEYSTORE_PASSWORD=QKZv1hSWAFQYZ+WU1jjF5ank+l4igeOfQRp+OSbkkrs
TRUSTSTORE_PASSWORD=rHkWR1gDNW3R9hgbeRsT3OM3Ue0zwGtQqcFKJD2EXWE
CURR_DIR=$(cd $(dirname $0); pwd)
SUB_NET=ddc-network
# 每个节点的域名
NODE_HOSTS="nifi1,nifi2,nifi3"
CONFIG_DIR="config"
DEFAULT_IMAGE_TAG="gridsum/nifi-cluster:1.11.4"




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

echo "证书准备完成"
echo "开始准备镜像，检查构建镜像配置..."

#检查镜像所需文件是否齐全
NEED_FILES="authorizers.xml,bootstrap.conf,bootstrap-notification-services.xml,\
logback.xml,login-identity-providers.xml,nifi.properties,nifi-cluster.sh,state-management.xml";
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
docker build -t gridsum/nifi-cluster:1.11.4  $CURR_DIR/






#生成default.conf配置文件
touch $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
nifi_port=8443

OLD_IFS="$IFS"
IFS=","
arr=($NODE_HOSTS)
for nhost in ${arr[@]}
do
    echo "   server {                                            " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       listen $nifi_port;                              " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       server_name  $nhost;                            " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       ssl_certificate nifi-cert.pem;                  " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       ssl_certificate_key nifi-key.key;               " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       ssl_session_cache shared:SSL:1m;                " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       ssl_session_timeout 5m;                         " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       ssl_ciphers HIGH:!aNULL:!MD5;                   " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       ssl_prefer_server_ciphers on;                   " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       location / {                                    " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "           proxy_pass https://$nhost:$nifi_port/;      " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "       }                                               " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
    echo "   }                                                   " >> $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf
done


# 将 config/secure/nifi-key.key config/secure/nifi-cert.pem  config/nginx-nifi.conf 发送到 nginx文件夹下
nginx_dir=$(cd $(dirname $CURR_DIR);pwd)
mv $CURR_DIR/$CONFIG_DIR/nginx-nifi.conf $CURR_DIR/$CONFIG_DIR/secure/nifi-key.key \
    $CURR_DIR/$CONFIG_DIR/secure/nifi-cert.pem  $nginx_dir/
