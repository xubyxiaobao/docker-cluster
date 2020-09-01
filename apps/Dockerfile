ARG REGISTRY
ARG BASIC_IMAGE=${BASIC_IMAGE}
FROM ${REGISTRY}${BASIC_IMAGE}

ARG package
ENV APP=${package}

COPY ./${package}  ./docker-entrypoint.sh /opt/

RUN chmod a+x /opt/docker-entrypoint.sh && \
    mkdir -p /opt/logs

VOLUME /opt/logs

WORKDIR /opt

ENTRYPOINT ["/opt/docker-entrypoint.sh"]

