#!/usr/bin/env bash

ZK_DATA_DIR=${ZK_DATA_DIR:-"/opt/zk/data"}
ZK_INIT_LIMIT=${ZK_INIT_LIMIT:-"10"}
ZK_MAX_CLIENT_CXNS=${ZK_MAX_CLIENT_CXNS:-"500"}
ZK_SYNC_LIMIT=${ZK_SYNC_LIMIT:-"5"}
ZK_TICK_TIME=${ZK_TICK_TIME:-"2000"}

cat << EOF > ${SERVICE_VOLUME}/confd/etc/conf.d/myid.toml
[template]
prefix = "/self/container"
src = "myid.tmpl"
dest = "${ZK_DATA_DIR}/myid"
owner = "${SERVICE_USER}"
mode = "0644"
keys = [
  "/service_index",
]
EOF

cat << EOF > ${SERVICE_VOLUME}/confd/etc/templates/myid.tmpl
{{getv "/service_index"}}
EOF

cat << EOF > ${SERVICE_VOLUME}/confd/etc/conf.d/zoo.cfg.toml
[template]
prefix = "/self/service"
src = "zoo.cfg.tmpl"
dest = "${SERVICE_HOME}/conf/zoo.cfg"
owner = "${SERVICE_USER}"
mode = "0644"
keys = [
  "/containers",
]

reload_cmd = "${SERVICE_VOLUME}/scripts/zk-service.sh restart"
EOF

cat << EOF > ${SERVICE_VOLUME}/confd/etc/templates/zoo.cfg.tmpl
tickTime=${ZK_TICK_TIME}
initLimit=${ZK_INIT_LIMIT}
syncLimit=${ZK_SYNC_LIMIT}
dataDir=${ZK_DATA_DIR}
maxClientCnxns=${ZK_MAX_CLIENT_CXNS}
clientPort=2181
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
{{range \$i, \$containerName := ls "/containers"}}
server.{{getv (printf "/containers/%s/service_index" \$containerName)}}={{getv (printf "/containers/%s/primary_ip" \$containerName)}}:2888:3888{{end}}
EOF


