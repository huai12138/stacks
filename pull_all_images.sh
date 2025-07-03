#!/bin/bash

# 脚本说明：批量管理 Docker Compose 容器
# 用法：./pull_all_images.sh [pull]
#   无参数或 pull: 拉取最新镜像并重启容器
#   no-pull: 仅重启容器，不拉取镜像
# 可选：sudo loginctl enable-linger $(whoami)

# 设置目标根目录
root_dir="/mnt/user/data/appdata/stacks"

# 解析命令行参数
PULL_IMAGES=${1:-"pull"}  # 默认拉取镜像，可选: pull, no-pull

# 统计信息
total_compose_files=0
success_count=0
failed_count=0

if [ "$PULL_IMAGES" == "pull" ]; then
  echo "开始更新所有容器（拉取镜像）..."
else
  echo "开始重启所有容器（不拉取镜像）..."
fi
echo "目标目录: $root_dir"
echo "----------------------------------------"

# 创建临时文件来保存统计信息
temp_dir=$(mktemp -d)
total_file="$temp_dir/total"
success_file="$temp_dir/success"
failed_file="$temp_dir/failed"

# 初始化计数文件
echo "0" > "$total_file"
echo "0" > "$success_file"
echo "0" > "$failed_file"

# 遍历目录及子目录
find "$root_dir" -name "compose.yaml" | while read compose_file; do
  # 读取并更新计数
  total=$(cat "$total_file")
  total=$((total + 1))
  echo "$total" > "$total_file"
  
  if [ "$PULL_IMAGES" == "pull" ]; then
    echo "[$total] 更新并重启容器: $compose_file"
  else
    echo "[$total] 重启容器: $compose_file"
  fi
  
  # 进入目录并执行操作
  dir_name=$(dirname "$compose_file")
  (
    cd "$dir_name" || { echo "错误：无法进入目录 $dir_name"; exit 1; }
    
    if [ "$PULL_IMAGES" == "pull" ]; then
      # 停止容器，拉取最新镜像，然后启动
      if podman-compose down && podman-compose pull && podman-compose up -d; then
        echo "  ✓ 成功更新: $compose_file"
        success=$(cat "$success_file")
        success=$((success + 1))
        echo "$success" > "$success_file"
      else
        echo "  ✗ 更新失败: $compose_file"
        failed=$(cat "$failed_file")
        failed=$((failed + 1))
        echo "$failed" > "$failed_file"
      fi
    else
      # 仅重启容器
      if podman-compose up -d; then
        echo "  ✓ 成功重启: $compose_file"
        success=$(cat "$success_file")
        success=$((success + 1))
        echo "$success" > "$success_file"
      else
        echo "  ✗ 重启失败: $compose_file"
        failed=$(cat "$failed_file")
        failed=$((failed + 1))
        echo "$failed" > "$failed_file"
      fi
    fi
  )
done

# 读取最终统计数据
total_compose_files=$(cat "$total_file")
success_count=$(cat "$success_file")
failed_count=$(cat "$failed_file")

# 清理临时文件
rm -rf "$temp_dir"

echo "----------------------------------------"

# 只有在拉取镜像时才清理无用镜像
if [ "$PULL_IMAGES" == "pull" ]; then
  echo "清理无用镜像..."
  if podman image prune -f; then
    echo "✓ 无用镜像清理完成"
  else
    echo "✗ 镜像清理失败"
  fi
fi

# 输出操作总结
if [ "$PULL_IMAGES" == "pull" ]; then
  echo "所有容器更新操作完成！"
else
  echo "所有容器重启操作完成！"
fi
echo "统计信息："
echo "  总计处理: $total_compose_files 个容器"
echo "  成功: $success_count 个"
echo "  失败: $failed_count 个"