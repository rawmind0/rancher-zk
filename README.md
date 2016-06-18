rancher-zk
==============

This image is the zookeeper dynamic conf for rancher. It comes from [rawmind/rancher-tools][rancher-tools].

## Build

```
docker build -t rawmind/rancher-zk:<version> .
```

## Versions

- `3.4.8-2` [(Dockerfile)](https://github.com/rawmind0/rancher-zk/blob/3.4.8-2/README.md)
- `3.4.6-4` [(Dockerfile)](https://github.com/rawmind0/rancher-zk/blob/3.4.6-4/README.md)


## Usage

This image has to be run as a sidekick of [rawmind/alpine-zk][alpine-zk], and makes available /opt/tools volume. It scans from rancher-metadata, for a zookeeper stack and generates /opt/zk/conf/zoo.cfg and /opt/zk/conf/myid dynamicly.


[alpine-zk]: https://github.com/rawmind0/alpine-zk
[rancher-tools]: https://github.com/rawmind0/rancher-tools
