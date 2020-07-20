ARG REGISTRY=${REGISTRY}
FROM ${REGISTRY}nginx:1.19.0


# 复制配置文件到容器中 ./nifi.conf

COPY ./nifi-key.key  ./nifi-cert.pem   ./nginx.conf   /etc/nginx/
COPY  ./conf.d/*  /etc/nginx/conf.d/
