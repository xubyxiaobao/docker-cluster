ARG REGISTRY=${REGISTRY}
ARG BASIC_IMAGE=${BASIC_IMAGE}
FROM ${REGISTRY}${BASIC_IMAGE}
    # redis主从所需要的配置
ENV BIND_IP=0.0.0.0 \
    PASSWORD="" \
    PROTECTED_MODE="no" \
    PORT=6379 \
    # cluster相关
    CLUSTER_ENABLED="yes" \
    CLUSTER_CONFIG_FILE="nodes.conf" \
    CLUSTER_NODE_TIMEOUT="15000" \
    # 外网ip port
    ANNOUNCE_IP="" \
    ANNOUNCE_PORT="" \
    ANNOUNCE_BUS_PORT=""

# 复制配置文件到容器中
COPY ./redis_template.conf  ./docker-entrypoint.sh /data/

# 移动脚本docker-entrypoint.sh到 /usr/local/bin/，覆盖docker-entrypoint.sh
RUN chown redis:redis /data/* \
    && chmod a+x /data/docker-entrypoint.sh \
    && \mv /data/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["redis-server"]