FROM rawmind/rancher-tools:3.7-0
MAINTAINER Raul Sanchez <rawmind@gmail.com>

#Set environment
ENV SERVICE_NAME=zk \
    SERVICE_USER=zookeeper \
    SERVICE_UID=10002 \
    SERVICE_GROUP=zookeeper \
    SERVICE_GID=10002 \
    SERVICE_HOME=/opt/zk \
    SERVICE_ARCHIVE=/opt/zk-rancher-tools.tgz

# Add files
ADD root /
RUN cd ${SERVICE_VOLUME} && \
    chmod 755 ${SERVICE_VOLUME}/scripts/*.sh  ${SERVICE_VOLUME}/confd/bin/*.sh && \
    tar czvf ${SERVICE_ARCHIVE} * && \ 
    rm -rf ${SERVICE_VOLUME}/* 
