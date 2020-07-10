FROM ${REGISTRY}nginx:1.19.0


# 复制配置文件到容器中
COPY ./nifi-key.key  ./nifi-cert.pem  ./nginx-nifi.conf    /etc/nginx/

RUN mv /etc/nginx/nginx-nifi.conf /etc/nginx/conf.d/nginx-nifi.conf