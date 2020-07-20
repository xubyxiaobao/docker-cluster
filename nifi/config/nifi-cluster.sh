#!/bin/bash
# 参数检测 NODE_HOST 是否为空、NODE_HOST是否在SUPPORT_HOSTS中


if [[ -z "$NODE_HOST" ]]; then
    echo -e "\033[31m属性NODE_HOST必须有值 \033[0m"      ## 红色
    exit 127
fi

hosts=$(echo "$SUPPORT_HOSTS" | sed 's/|/,/g'|awk '{print substr($0,2,length($0)-2)}')

#if [[ "$SUPPORT_HOSTS" != *"|${NODE_HOST}|"* ]]; then
#    echo -e "\033[31m属性NODE_HOST必须为 ${hosts}中已存在的域名 \033[0m"
#    exit 127
#fi

if [[ -z "$NIFI_CLUSTER_NODE_ADDRESS" ]]; then
    echo -e "\033[31mNIFI_CLUSTER_NODE_ADDRESS必须有值 \033[0m"      ## 红色
    exit 127
fi

rm -rf $NIFI_HOME/conf/*
cp ${NIFI_BASE_DIR}/tmp/bootstrap.conf ${NIFI_BASE_DIR}/tmp/bootstrap-notification-services.xml  \
   ${NIFI_BASE_DIR}/tmp/authorizers.xml ${NIFI_BASE_DIR}/tmp/login-identity-providers.xml  \
   ${NIFI_BASE_DIR}/tmp/nifi.properties  ${NIFI_BASE_DIR}/tmp/state-management.xml  \
   ${NIFI_BASE_DIR}/tmp/logback.xml  ${NIFI_HOME}/conf/ 

cp ${NIFI_BASE_DIR}/tmp/$NODE_HOST/keystore.jks  ${KEYSTORE_PATH} &&
cp ${NIFI_BASE_DIR}/tmp/$NODE_HOST/truststore.jks  ${TRUSTSTORE_PATH} 


function updateConfig() {
    key=$1
    value=$2
    file=$3
    echo "[Configuring] '$key=$value' in '$file'"
    if grep -E -q "^#?$key=" "$file"; then
        sed -r -i "s@^#?$key=.*@$key=$value@g" "$file" #note that no config values may contain an '@' char
    fi
}
#根据环境变量更新文件
## bootstrap.conf
OLD_IFS="$IFS"
IFS=$'\n'
for VAR in  $(env)
do
    env_var=$(echo "$VAR" | cut -d= -f1)
    if [[ $env_var =~ ^JAVA_ARG_[0-9]+ ]]; then
        prop_name=$(echo "$env_var" | tr '[:upper:]' '[:lower:]' | tr _ .)
        updateConfig "$prop_name" "${!env_var}" "$NIFI_HOME/conf/bootstrap.conf"
    fi
done
IFS="$OLD_IFS"

##更新nifi.properties
updateConfig "nifi.web.http.host" "" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.web.http.port" "" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.web.https.host" "$NODE_HOST" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.web.https.port" "$HTTPS_PORT" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.security.keystore" "$KEYSTORE_PATH" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.security.keystoreType" "$KEYSTORE_TYPE" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.security.keystorePasswd" "$KEYSTORE_PASSWORD" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.security.keyPasswd" "$KEYSTORE_PASSWORD" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.security.truststore" "$TRUSTSTORE_PATH" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.security.truststorePasswd" "$TRUSTSTORE_PASSWORD" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.security.truststoreType" "$TRUSTSTORE_TYPE" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.cluster.node.address" "$NIFI_CLUSTER_NODE_ADDRESS" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.cluster.node.protocol.port" "$NIFI_CLUSTER_NODE_PROTOCOL_PORT" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.zookeeper.connect.string" "$NIFI_ZK_CONNECT_STRING" "$NIFI_HOME/conf/nifi.properties"
updateConfig "nifi.zookeeper.root.node" "$NIFI_ZK_ROOT_NODE" "$NIFI_HOME/conf/nifi.properties"

## authorizers.xml  根据  SUPPORT_HOSTS   INITIAL_ADMIN_IDENTITY 生成授权配置
tmp_users="<property name=\"Initial User Identity 1\">${INITIAL_ADMIN_IDENTITY}</property>"
tmp_nodes="";
OLD_IFS="$IFS"
IFS=','
arr=($hosts)
index=2
for VAR in ${arr[@]}
do
    tmp_users="${tmp_users}<property name=\"Initial User Identity ${index}\">CN=${VAR}, OU=NIFI</property>"
    tmp_nodes="${tmp_nodes}<property name=\"Node Identity ${index}\">CN=${VAR}, OU=NIFI</property>"
    index=$((index+1))
done
IFS="$OLD_IFS"

### 1、替换<property name="Initial User Identity 1"></property>，初始化授权用户
sed -i -e 's|<property name="Initial User Identity 1"></property>|'"${tmp_users}"'|'  ${NIFI_HOME}/conf/authorizers.xml
echo "${NIFI_HOME}/conf/authorizers.xml :${tmp_users}"

### 2、替换<property name="Initial Admin Identity"></property>，初始化管理员
sed -i -e 's|<property name="Initial Admin Identity"></property>|<property name="Initial Admin Identity">'"${INITIAL_ADMIN_IDENTITY}"'</property>|'  ${NIFI_HOME}/conf/authorizers.xml
echo "${NIFI_HOME}/conf/authorizers.xml :${INITIAL_ADMIN_IDENTITY}"

### 3、替换<property name="Node Identity 1"></property>，初始化集群安全节点
sed -i -e 's|<property name="Node Identity 1"></property>|'"${tmp_nodes}"'|'  ${NIFI_HOME}/conf/authorizers.xml
echo "${NIFI_HOME}/conf/authorizers.xml :${tmp_nodes}"


## state-management.xml
### 1、替换<property name="Connect String"></property>
sed -i -e 's|<property name="Connect String"></property>|<property name="Connect String">'"${NIFI_ZK_CONNECT_STRING}"'</property>|'  ${NIFI_HOME}/conf/state-management.xml

### 2、替换<property name="Root Node"></property>
sed -i -e 's|<property name="Root Node"></property>|<property name="Root Node">'"${NIFI_ZK_ROOT_NODE}"'</property>|'  ${NIFI_HOME}/conf/state-management.xml


## login-identity-providers.xml
###1、<property name="Authentication Strategy"></property>
sed -i -e 's|<property name="Authentication Strategy"></property>|<property name="Authentication Strategy">'"${LDAP_AUTHENTICATION_STRATEGY}"'</property>|'  ${NIFI_HOME}/conf/login-identity-providers.xml

###2、<property name="Manager DN"></property>
sed -i -e 's|<property name="Manager DN"></property>|<property name="Manager DN">'"${LDAP_MANAGER_DN}"'</property>|'  ${NIFI_HOME}/conf/login-identity-providers.xml

###3、<property name="Manager Password"></property>
sed -i -e 's|<property name="Manager Password"></property>|<property name="Manager Password">'"${LDAP_MANAGER_PASSWORD}"'</property>|'  ${NIFI_HOME}/conf/login-identity-providers.xml

###4、<property name="User Search Base"></property>
sed -i -e 's|<property name="User Search Base"></property>|<property name="User Search Base">'"${LDAP_USER_SEARCH_BASE}"'</property>|'  ${NIFI_HOME}/conf/login-identity-providers.xml

###5、<property name="Url"></property>
sed -i -e 's|<property name="Url"></property>|<property name="Url">'"${LDAP_URL}"'</property>|'  ${NIFI_HOME}/conf/login-identity-providers.xml

###6、<property name="User Search Filter"></property>
sed -i -e 's|<property name="User Search Filter"></property>|<property name="User Search Filter">'"${LDAP_USER_SEARCH_FILTER}"'</property>|'  ${NIFI_HOME}/conf/login-identity-providers.xml

###7、<property name="Identity Strategy"></property>
sed -i -e 's|<property name="Identity Strategy"></property>|<property name="Identity Strategy">'"${LDAP_IDENTITY_STRATEGY}"'</property>|'  ${NIFI_HOME}/conf/login-identity-providers.xml


### 删除bootstrap.conf配置文件中run.as配置
sed -i 's/run.as.*/ /g' "$NIFI_HOME/conf/bootstrap.conf"


echo "" >> "${NIFI_HOME}/logs/nifi-app.log"

"${NIFI_HOME}/bin/nifi.sh" run &
nifi_pid="$!"

tail -F --pid=${nifi_pid} "${NIFI_HOME}/logs/nifi-app.log" &

trap 'echo Received trapped signal, beginning shutdown...;./bin/nifi.sh stop;exit 0;' TERM HUP INT;
trap ":" EXIT

echo NiFi running with PID ${nifi_pid}.
wait ${nifi_pid}