ARG REGISTRY=${REGISTRY}
ARG BASIC_IMAGE=${BASIC_IMAGE}
FROM ${REGISTRY}${BASIC_IMAGE}


# 复制配置文件到容器中 ./nifi.conf

COPY ./nifi-key.key  ./nifi-cert.pem   ./nginx.conf   /etc/nginx/
COPY  ./conf.d/*  /etc/nginx/conf.d/
