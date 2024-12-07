#!/bin/bash

# 设置目标根目录
root_dir="/mnt/data/appdata/stacks"

# 遍历目录及子目录
find "$root_dir" -name "compose.yaml" | while read compose_file; do
  echo "更新并重启容器: $compose_file"
  
  # 进入目录并执行更新操作
  dir_name=$(dirname "$compose_file")
  (
    cd "$dir_name"
    
    # 拉取镜像
    sudo docker-compose pull
    
    # 重启容器
    sudo docker-compose up -d
  )
done
# 清理无用镜像
echo "清理无用镜像..."
sudo docker image prune -f

echo "所有容器已更新并重启完成！无用镜像已清理！"

