#!/usr/bin/env bash

MONIT_SERVICE_NAME=zk-service
CONF_HOME=${CONF_HOME:-"${SERVICE_VOLUME}/confd"}
CONF_LOG=${CONF_LOG:-"${CONF_HOME}/log/confd.log"}
CONF_PREFIX=${CONF_PREFIX:-"/2015-12-19"}
CONF_URL="http://rancher-metadata.rancher.internal${CONF_PREFIX}"
JQ_BIN=${JQ_BIN:-${SERVICE_VOLUME}"/scripts/jq -r"}


function log {
        echo `date` $ME - $@ >> ${CONF_LOG} 2>&1
}

function myZkid {
    curl -Ss ${CONF_URL}/self/container/service_index
}

function waitDeploy {
    log "[ Waiting replicas to be started ... ]"

    current_rep=$(curl -Ss ${CONF_URL}/self/service/containers | wc -l)
    wanted_rep=$(curl -Ss ${CONF_URL}/self/service/scale)

    while [ ${current_rep} -ne ${wanted_rep} ]; do
        log "${current_rep} of ${wanted_rep} started conatiners....waiting..."
        sleep 3
    done
}

function getLeader {
    node_leader="none"

for i in `curl -Ss ${CONF_URL}/self/service/containers | cut -d"=" -f1
`; do echo - $(curl -Ss ${CONF_URL}/self/service/containers/$i/primary_ip) ;done

    for i in $(curl -Ss ${CONF_URL}/self/service/containers | cut -d"=" -f1)  
    do 
        node_ip=$(curl -Ss ${CONF_URL}/self/service/containers/$i/primary_ip)
        node_role=$(echo stat | nc ${node_ip}:2181 | grep -w Mode: | cut -d' ' -f2)
        if [ "${node_role}" == "leader" ]; then
            node_leader=${node_ip}
            break
        fi
    done

    echo $node_leader
}

function nodeStatus {
    echo ruok | nc $HOSTNAME:2181
}

function nodeRestart {
    log "[ Restarting $MONIT_SERVICE_NAME ... ]"

    if [ "$(nodeStatus)" == "imok" ]; then
        leader=$(getLeader)

        if [ "$leader" != "none" ]; then
            synced_follow=$(echo mntr | nc ${leader}:2181 | grep -w zk_synced_followers | cut -f2)
         
            while [ ${synced_follow} -le 1 ]; do
                log "Only ${synced_follow} synced follower. Waiting ..."
                sleep 5
                synced_follow=$(echo mntr | nc ${leader}:2181 | grep -w zk_synced_followers | cut -f2)
            done
            log "${synced_follow} synced follower. Restarting ..."
        fi
    fi

    /opt/monit/bin/monit restart $MONIT_SERVICE_NAME
}

case "$1" in
        "restart")
            nodeRestart >> ${CONF_LOG} 2>&1
        ;;
        *) echo "Usage: $0 restart"
        ;;

esac

