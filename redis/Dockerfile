FROM redis:5.0.9

#
ENV REDIS_DIR="/redis/data" \
	REDIS_CONFIG_PATH="/redis/config"

# 复制配置文件到容器中
COPY ./redis.conf  ./sentinel.conf ./docker-entrypoint.sh /data/

# 移动脚本docker-entrypoint.sh到 /usr/local/bin/，覆盖docker-entrypoint.sh
RUN chown redis:redis /data/* \
    && chmod a+x /data/docker-entrypoint.sh \
    && \mv /data/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
