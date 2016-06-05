FROM rawmind/rancher-tools:0.3.3-0
MAINTAINER Raul Sanchez <rawmind@gmail.com>

#Set environment
ENV SERVICE_NAME=zk \
    SERVICE_USER=zookeeper \
    SERVICE_UID=10002 \
    SERVICE_GROUP=zookeeper \
    SERVICE_GID=10002

# Add service files
ADD root /
RUN chmod +x /opt/tools/${CONF_NAME}/bin/*.sh

CMD ["chown", "-R", "${SERVICE_UID}:${SERVICE_GID}", "/opt/tools"]