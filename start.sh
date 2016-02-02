#!/bin/bash

set -e

function log {
        echo `date` $ME - $@
}

function checkrancher {
    log "checking rancher network..."
    a="`ip a s dev eth0 &> /dev/null; echo $?`"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`" 
        sleep 1
    done

   b="`ping -c 1 rancher-metadata &> /dev/null; echo $?`"
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

function rmconfd {
    if [ -f /etc/monit/conf.d/confd.conf ]; then
        rm /etc/monit/conf.d/confd.conf
    fi
}

CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}
CONFD_PREFIX=${CONFD_PREFIX:-"/2015-12-19"}
CONFD_INTERVAL=${CONFD_INTERVAL:-60}
CONFD_PARAMS=${CONFD_PARAMS:-"-backend ${CONFD_BACKEND} -prefix ${CONFD_PREFIX}"}
CONFD_ONETIME="/usr/bin/confd -onetime ${CONFD_PARAMS}"
CONFD_SCRIPT=${CONFD_SCRIPT:-"/tmp/confd-start.sh"}
JVMFLAGS=${JVMFLAGS:-"-Xms512m -Xmx512m"}

export CONFD_BACKEND CONFD_PREFIX CONFD_INTERVAL CONFD_PARAMS JVMFLAGS

checkrancher
taillog

if [ "$CONFD_INTERVAL" -gt "0" ]; then
    CONFD_PARAMS="-interval ${CONFD_INTERVAL} ${CONFD_PARAMS}"

    # Create confd start script
    echo "#!/usr/bin/env sh" > ${CONFD_SCRIPT}
    echo "/usr/bin/nohup /usr/bin/confd ${CONFD_PARAMS} > /opt/zk/logs/confd.log 2>&1 &" >> ${CONFD_SCRIPT}
    echo "rc=\$?" >> ${CONFD_SCRIPT}
    echo "echo \$rc" >> ${CONFD_SCRIPT}
    chmod 755 ${CONFD_SCRIPT}

    log "[ Refreshing zk configuration every ${CONFD_INTERVAL} seconds... ]"
else
    #Execute confd in onepass. Removing confd monit script
    log "[ Static zk configuration... ]"
    rmconfd
fi

# Run confd to get first appli configuration
log "[ Getting zk configuration... ]"
${CONFD_ONETIME}

# Run monit
log "[ Starting monit... ]"
/usr/bin/monit -I
