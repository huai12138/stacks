#!/bin/bash

# 设置目标根目录
root_dir="/mnt/user/data/appdata/stacks"

# 添加命令行参数支持
PULL_IMAGES=${1:-"yes"}  # 默认拉取镜像，可选: yes, no

# 遍历目录及子目录
find "$root_dir" -name "compose.yaml" | while read compose_file; do
  if [ "$PULL_IMAGES" == "yes" ]; then
    echo "更新并重启容器: $compose_file"
  else
    echo "重启容器(不拉取镜像): $compose_file"
  fi
  
  # 进入目录并执行操作
  dir_name=$(dirname "$compose_file")
  (
    cd "$dir_name"
    
    # 根据参数决定是否拉取镜像
    if [ "$PULL_IMAGES" == "yes" ]; then
      # 拉取镜像
      podman-compose pull
    fi
    
    # 重启容器
    podman-compose up -d
  )
done

# 只有在拉取镜像时才清理无用镜像
if [ "$PULL_IMAGES" == "yes" ]; then
  # 清理无用镜像
  echo "清理无用镜像..."
  podman image prune -f
  echo "所有容器已更新并重启完成！无用镜像已清理！"
else
  echo "所有容器已重启完成！(未拉取新镜像)"
fi

