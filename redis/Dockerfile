FROM redis:5.0.9
    # redis主从所需要的配置
ENV BIND_ID=0.0.0.0 \
    SLAVEOF="" \
    PASSWORD="" \
    PROTECTED_MODE="no" \
    PORT=6379 \
    # sentinel 所需配置
    SENTINEL_NAME="" \
    SENTINEL_MASTER="" \
    SENTINEL_AUTHPASS="" \
    SENTINEL_DOWN_AFTER=30000 \
    SENTINEL_PARALLEL_SYNCS=1 \
    SENTINEL_FAILOVER_TIMEOUT=180000

# 复制配置文件到容器中
COPY ./redis.conf  ./sentinel.conf ./docker-entrypoint.sh /data/

# 移动脚本docker-entrypoint.sh到 /usr/local/bin/，覆盖docker-entrypoint.sh
RUN chown redis:redis /data/* \
    && chmod a+x /data/docker-entrypoint.sh \
    && \mv /data/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["redis-server"]