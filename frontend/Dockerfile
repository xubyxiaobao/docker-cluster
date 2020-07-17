ARG REGISTRY=${REGISTRY}
FROM ${REGISTRY}nginx:1.19.0

COPY ./nginx.conf/  /etc/nginx/
COPY ./conf.d/* /etc/nginx/conf.d/
COPY  ./frontend.tar /opt/
RUN  tar -xf /opt/frontend.tar -C /opt/
