ARG REGISTRY
FROM ${REGISTRY}openjdk:8u252-jdk-buster

ARG package
ENV APP=${package}

COPY ./${package}  ./docker-entrypoint.sh /opt/

RUN chmod a+x /opt/docker-entrypoint.sh && \
    mkdir -p /opt/logs

VOLUME /opt/logs

WORKDIR /opt

ENTRYPOINT ["/opt/docker-entrypoint.sh"]

