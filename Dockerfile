FROM rawmind/rancher-jvm8:0.0.2
MAINTAINER Raul Sanchez <rawmind@gmail.com>

ENV ZOO_VERSION=3.4.6 \
    ZOO_HOME=/opt/zk \ 
    ZOO_LOG_DIR=/opt/zk/logs \
    PATH=/opt/zk/bin:${PATH}
ENV ZOO_RELEASE=zookeeper-${ZOO_VERSION}

RUN curl -sS -k http://apache.rediris.es/zookeeper/${ZOO_RELEASE}/${ZOO_RELEASE}.tar.gz | gunzip -c - | tar -xf - -C /opt \
  && mv /opt/zookeeper-* ${ZOO_HOME} \
  && mkdir -p ${ZOO_LOG_DIR} ${ZOO_HOME}/data \
  && chmod +x ${ZOO_HOME}/bin/zkServer.sh 

# Add confd tmpl and toml
ADD confd/*.toml /etc/confd/conf.d/
ADD confd/*.tmpl /etc/confd/templates/

# Add monit conf for services
ADD monit/*.conf /etc/monit/conf.d/

# Add start script
ADD start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

WORKDIR $ZOO_HOME

ENTRYPOINT ["/usr/bin/start.sh"]
