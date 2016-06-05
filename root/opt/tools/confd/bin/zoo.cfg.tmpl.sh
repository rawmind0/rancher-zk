#!/usr/bin/env sh

cat << EOF > /opt/tools/${CONF_NAME}/etc/templates/zoo.cfg.tmpl
tickTime=${ZK_TICK_TIME}
initLimit=${ZK_INIT_LIMIT}
syncLimit=${ZK_SYNC_LIMIT}
dataDir=${ZK_DATA_DIR}
maxClientCnxns=${ZK_MAX_CLIENT_CXNS}
clientPort=2181
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
{{range $i, $containerName := ls "/containers"}}
server.{{getv (printf "/containers/%s/service_index" $containerName)}}={{getv (printf "/containers/%s/primary_ip" $containerName)}}:2888:3888{{end}}
EOF
