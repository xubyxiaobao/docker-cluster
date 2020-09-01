ARG REGISTRY=${REGISTRY}
ARG BASIC_IMAGE=${BASIC_IMAGE}
FROM ${REGISTRY}${BASIC_IMAGE}

#复制mongokey
ENV MONGO_KEY_PATH=/data/mongodb.key

RUN mkdir -p  $(dirname $MONGO_KEY_PATH)
COPY ./mongodb.key $MONGO_KEY_PATH
RUN chmod 400 /data/mongodb.key \
    && chown mongodb:mongodb  /data/mongodb.key
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mongod"]