ARG REGISTRY=${REGISTRY}
ARG BASIC_IMAGE=${BASIC_IMAGE}
FROM ${REGISTRY}${BASIC_IMAGE}

#nifi.properties  集群+认证
ENV NODE_HOST='' \
    NIFI_CLUSTER_NODE_ADDRESS='' \
    HTTPS_PORT=9443 \
    KEYSTORE_PATH=./conf/keystore.jks \
    KEYSTORE_TYPE=JKS \
    KEYSTORE_PASSWORD=QKZv1hSWAFQYZ+WU1jjF5ank+l4igeOfQRp+OSbkkrs \
    TRUSTSTORE_PATH=./conf/truststore.jks \
    TRUSTSTORE_PASSWORD=rHkWR1gDNW3R9hgbeRsT3OM3Ue0zwGtQqcFKJD2EXWE \
    TRUSTSTORE_TYPE=JKS \
    NIFI_CLUSTER_NODE_ADDRESS='' \
    NIFI_CLUSTER_NODE_PROTOCOL_PORT=11443 \
    NIFI_ZK_CONNECT_STRING=zoo1:2181,zoo2:2181,zoo3:2181 \
    NIFI_ZK_ROOT_NODE=/nifi \
    #bootstrap.conf 调整内存大小
    JAVA_ARG_2=-Xms2048m   \
	JAVA_ARG_3=-Xmx2048m   \
    #authorizers.xml  授权   
    SUPPORT_HOSTS="|nifi1|nifi2|nifi3|" \
    #login-identity-providers.xml 认证
    INITIAL_ADMIN_IDENTITY='admin' \
    LDAP_AUTHENTICATION_STRATEGY='SIMPLE' \
    LDAP_MANAGER_DN='cn=admin,dc=gridsum,dc=com' \
    LDAP_MANAGER_PASSWORD='123456' \
    LDAP_USER_SEARCH_BASE='dc=gridsum,dc=com' \
    LDAP_USER_SEARCH_FILTER='cn={0}' \
    LDAP_IDENTITY_STRATEGY='USE_USERNAME' \
    LDAP_URL='ldap://openldap:389' 
# 复制配置文件与运行脚本到镜像
#   bootstrap.conf 启动参数
#   bootstrap-notification-services.xml 容器通知
#   authorizers.xml 授权
#   login-identity-providers.xml 登录
#   nifi.properties
#   state-management.xml 状态存储
#   nifi-cluster.sh 集群启动脚本


RUN  mkdir  ${NIFI_BASE_DIR}/tmp
COPY config/bootstrap.conf  config/bootstrap-notification-services.xml  config/authorizers.xml \
     config/login-identity-providers.xml  config/nifi.properties   config/state-management.xml \
     config/logback.xml config/nifi-cluster.sh  config/secure/  ${NIFI_BASE_DIR}/tmp/

USER root

RUN chown -R nifi:nifi ${NIFI_BASE_DIR}/tmp/* \
   && chmod a+x ${NIFI_BASE_DIR}/tmp/nifi-cluster.sh \
   && cp ${NIFI_BASE_DIR}/tmp/nifi-cluster.sh  ${NIFI_BASE_DIR}/scripts/ 


USER nifi

EXPOSE ${HTTPS_PORT}

ENTRYPOINT ["../scripts/nifi-cluster.sh"]

