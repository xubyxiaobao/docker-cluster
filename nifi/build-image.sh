#!/bin/bash
# docker镜像的版本号
keystore_password=QKZv1hSWAFQYZ+WU1jjF5ank+l4igeOfQRp+OSbkkrs
truststore_password=rHkWR1gDNW3R9hgbeRsT3OM3Ue0zwGtQqcFKJD2EXWE
dir=$(cd $(dirname $0);pwd);
#必须与docker-stack.yml文件中对应的服务名相同
node_hosts="nifi1,nifi2,nifi3"
config_path="config"


#3、生成证书文件夹
rm -rf ${dir}/${config_path}/secure  \
&& mkdir -p ${dir}/${config_path}/secure  \
&& chmod  777 ${dir}/${config_path}/secure
echo "清理${dir}/${config_path}/secure完成"


#2、开始生成证书：
echo "开始生成集群证书..."
echo "证书生成路径：${dir}/${config_path}/secure"
echo "证书域名：${node_hosts}"
echo "证书类型：JKS"
echo "证书keyStorePassword：${keystore_password}"
echo "证书trustStorePassword: ${truststore_password}"

#2、生成证书，nifi开启https所必须
docker run --rm --name nifi-tool -it  -v ${dir}/${config_path}/secure:/data/  \
--entrypoint /bin/bash apache/nifi:1.11.4 \
/opt/nifi/nifi-toolkit-current/bin/tls-toolkit.sh standalone \
-n "${node_hosts}" -o '/data' -O 'true' \
-C 'cn=admin,dc=gridsum,dc=com' \
-S ${keystore_password} -P ${truststore_password}


# 检查证书是否生成成功
OLD_IFS="$IFS"
IFS=","
arr=(${node_hosts})
for VAR in ${arr[@]}
do
    if [ ! -d ${dir}/${config_path}/secure/$VAR ] ; then
        echo -e "\033[31m证书生成失败：缺少${dir}/${config_path}/secure/$VAR \033[0m"
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
    if [ ! -f ${dir}/${config_path}/$VAR ]; then
        echo -e "\033[31m缺少配置文件${dir}/${config_path}/$VAR \033[0m"
        exit 127
    fi
done
IFS="$OLD_IFS"

echo "构建镜像配置检查完成"
docker build -t ${REGISTRY_HOST}${nifi_image}  ${dir}/


#生成nginx转发配置文件
touch ${dir}/${config_path}/nginx-nifi.conf
nifi_port=8443

OLD_IFS="$IFS"
IFS=","
arr=(${node_hosts})
for nhost in ${arr[@]}
do
    echo "   server {                                            " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       listen $nifi_port;                              " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       server_name  $nhost;                            " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       ssl_certificate nifi-cert.pem;                  " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       ssl_certificate_key nifi-key.key;               " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       ssl_session_cache shared:SSL:1m;                " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       ssl_session_timeout 5m;                         " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       ssl_ciphers HIGH:!aNULL:!MD5;                   " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       ssl_prefer_server_ciphers on;                   " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       location / {                                    " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "           proxy_pass https://$nhost:$nifi_port/;      " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "       }                                               " >> ${dir}/${config_path}/nginx-nifi.conf
    echo "   }                                                   " >> ${dir}/${config_path}/nginx-nifi.conf
done


# 将 config/secure/nifi-key.key config/secure/nifi-cert.pem  config/nginx-nifi.conf 移动到 nginx文件夹下
nginx_dir=$(cd ${dir}/../nginx; pwd);
mv ${dir}/${config_path}/nginx-nifi.conf ${dir}/${config_path}/secure/nifi-key.key \
    ${dir}/${config_path}/secure/nifi-cert.pem  $nginx_dir/
