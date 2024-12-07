#!/bin/bash

# 更新所有服务镜像
echo "Pulling docker images..."
docker compose pull

# 启动服务并在后台运行
echo "Starting docker containers..."
sudo docker compose up -d

echo "Docker containers are up and running!"

