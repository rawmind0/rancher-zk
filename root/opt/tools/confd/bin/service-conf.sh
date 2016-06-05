#!/usr/bin/env bash

set -e

function log {
        echo `date` $ME - $@ >> ${CONF_LOG}
}

function checkNetwork {
    log "[ Checking container ip... ]"
    a="`ip a s dev eth0 &> /dev/null; echo $?`"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`" 
        sleep 1
    done

    log "[ Checking container connectivity... ]"
    b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
    while [ $b -eq 1 ]; 
    do
        b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
        sleep 1 
    done
}

function serviceTemplate {
    log "[ Checking ${CONF_NAME} template... ]"
    if [ ! -f "/opt/tools/${CONF_NAME}/etc/templates/zoo.cfg.tmpl" ]; then
        /opt/tools/${CONF_NAME}/bin/zoo.cfg.tmpl.sh
    fi
}

function serviceStart {
    serviceTemplate
    log "[ Starting ${CONF_NAME}... ]"
    /usr/bin/nohup ${CONF_INTERVAL} > ${CONF_HOME}/log/confd.log 2>&1 &
}

function serviceStop {
    log "[ Stoping ${CONF_NAME}... ]"
    /usr/bin/killall confd
}

function serviceRestart {
    log "[ Restarting ${CONF_NAME}... ]"
    serviceStop
    checkNetwork 
    serviceStart
}

CONF_NAME=confd
CONF_HOME=${CONF_HOME:-"/opt/tools/confd"}
CONF_LOG=${CONF_LOG:-"${CONF_HOME}/log/confd.log"}
CONF_BIN=${CONF_BIN:-"${CONF_HOME}/bin/confd"}
CONF_BACKEND=${CONF_BACKEND:-"rancher"}
CONF_PREFIX=${CONF_PREFIX:-"/2015-12-19"}
CONF_INTERVAL=${CONF_INTERVAL:-60}
CONF_PARAMS=${CONF_PARAMS:-"-confdir /opt/tools/confd/etc -backend ${CONF_BACKEND} -prefix ${CONF_PREFIX}"}
CONF_ONETIME="${CONF_BIN} -onetime ${CONF_PARAMS}"
CONF_INTERVAL="${CONF_BIN} -interval ${CONF_INTERVAL} ${CONF_PARAMS}"

case "$1" in
        "start")
            serviceStart >> ${CONF_LOG} 2>&1
        ;;
        "stop")
            serviceStop >> ${CONF_LOG} 2>&1
        ;;
        "restart")
            serviceRestart >> ${CONF_LOG} 2>&1
        ;;
        *) echo "Usage: $0 restart|start|stop"
        ;;

esac
