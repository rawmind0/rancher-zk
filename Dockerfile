FROM rawmind/rancher-tools:0.3.3-1
MAINTAINER Raul Sanchez <rawmind@gmail.com>

#Set environment
ENV SERVICE_NAME=zk \
    SERVICE_USER=zookeeper \
    SERVICE_UID=10002 \
    SERVICE_GROUP=zookeeper \
    SERVICE_GID=10002 

# Add service files
ADD root /

