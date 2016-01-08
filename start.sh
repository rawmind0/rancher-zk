#!/bin/bash

set -e

function log {
        echo `date` $ME - $@
}

function checkrancher {
    log "checking rancher network..."
    a="1"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`" 
        sleep 1
    done

    b="1"
    while [ $b -eq 1 ]; 
    do
        b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
        sleep 1 
    done
}

function taillog {
    if [ -f ${ZOO_HOME}/logs/zookeeper.out ]; then
        rm ${ZOO_HOME}/logs/zookeeper.out
    fi
    tail -F ${ZOO_HOME}/logs/zookeeper.out &
}

function rmconf {
    if [ -f ${KAFKA_HOME}/config/server.properties ]; then
        rm ${KAFKA_HOME}/config/server.properties
    fi
}

CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}
CONFD_PREFIX=${CONFD_PREFIX:-"/2015-07-25"}
CONFD_INTERVAL=${CONFD_INTERVAL:-60}
CONFD_RELOAD=${CONFD_RELOAD:-true}
CONFD_PARAMS=${CONFD_PARAMS:-"-backend ${CONFD_BACKEND} -prefix ${CONFD_PREFIX}"}
JVMFLAGS=${JVMFLAGS:-"-Xms128m -Xmx256m"}

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS JVMFLAGS

checkrancher
rmconf

if [ "$CONFD_RELOAD" == "true" ]; then
    taillog

    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"
    confd ${CONFD_PARAMS}
else
    CONFD_PARAMS="-onetime ${CONFD_PARAMS}"
    confd ${CONFD_PARAMS}

    log "[ Starting kafka service... ]"
    ${ZOO_HOME}/bin/zkServer.sh start-foreground
fi
