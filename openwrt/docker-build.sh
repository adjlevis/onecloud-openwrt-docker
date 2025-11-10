#!/bin/bash
set -e

echo "🚀 启动自定义 OpenWRT RootFS 构建流程 (模拟 Docker 环境)..."

# 环境变量回显（可用于调试）
echo "👤 编译者: ${OP_author:-Unknown}"
echo "📦 RootFS 分区大小(忽略): ${OP_rootfs:-512}MB"

# 模拟调用 build.sh
if [[ -x ./build.sh ]]; then
  ./build.sh
else
  echo "⚠️ build.sh 不存在或无执行权限，跳过。"
fi

echo "✅ docker-build.sh 执行完成。"
