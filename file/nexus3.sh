#!/usr/bin/env bash
# 一键启动nexus3
# 用于docker代理缓存镜像
# 端口说明，
# docker group 端口 38380
# 默认密码进入容器 docker exec nexus3 cat /opt/sonatype/sonatype-work/nexus3/admin.password
mkdir -p /data/nexus/nexus-data
chmod 777 /data/nexus/nexus-data
docker run -d \
  -p 38380:38380 \
  -p 8081:8081 \
  --name nexus3 \
  -v /data/nexus/nexus-data:/nexus-data \
  --restart=always \
  sonatype/nexus3
