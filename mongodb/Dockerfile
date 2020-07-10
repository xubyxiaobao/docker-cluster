FROM ${REGISTRY}mongo:4.2.8-bionic

#复制mongokey
ENV MONGO_KEY_PATH=/data/mongodb.key

RUN mkdir -p  $(dirname $MONGO_KEY_PATH)
COPY ./mongodb.key $MONGO_KEY_PATH
RUN chmod 400 /data/mongodb.key \
    && chown mongodb:mongodb  /data/mongodb.key
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mongod"]