rancher-zk
============

rancher-zk image based in rancher-jvm8

To build

```
docker build -t <repo>/rancher-zk:<version> .
```

To run:

```
docker run -it <repo>/rancher-zk:<version> 
```

# How it works

* The docker has the entrypoint /usr/bin/start.sh, that it starts confd, checking a rancher-metadata server. It checks, reconfigures and restart the zookeeper cluster, every $CONFD_INTERVAL seconds.
* Zookeeper memory params could be set overriding JVMFLAGS env variable.
* Scale could be from 1 to n nodes. Recommended to use odd values: 3,5,7,...
* Default env variables values:
CONFD_BACKEND=${CONFD_BACKEND:-"rancher"}       # Default confd backend
CONFD_PREFIX=${CONFD_PREFIX:-"/2015-07-25"}     # Default prefix to rancher-metadata backend
CONFD_INTERVAL=${CONFD_INTERVAL:-60}            # Default check interval
RANCHER_METADATA=${RANCHER_METADATA:-"rancher-metadata.rancher.internal"}   # Default rancher-metadata server
JVMFLAGS=${JVMFLAGS:-"-Xms128m -Xmx256m"}       # Default zookeeper memory value
