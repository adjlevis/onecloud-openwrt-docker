#!/bin/bash
set -euo pipefail

# 可由 workflow 环境变量传入，默认值防护
: "${OP_rootfs:=512}"
: "${OP_author:=CI}"

echo "启动 OpenWRT Docker 构建... (OP_rootfs=$OP_rootfs OP_author=$OP_author)"

docker run --rm \
  -e OP_rootfs="$OP_rootfs" \
  -e OP_author="$OP_author" \
  -v "$(pwd)/bin:/builder/bin" \
  -v "$(pwd)/files:/builder/files" \
  -v "$(pwd)/build.sh:/builder/build.sh" \
  openwrt/imagebuilder:armsr-armv7 bash -eux -c '

# 候选路径优先检查（快速）
CANDIDATES="/home/build/openwrt /home/build /opt/openwrt /openwrt /openwrt-imagebuilder /workdir /"
ROOT=""
for d in $CANDIDATES; do
  if [ -f "$d/Makefile" ] && grep -q "^image:" "$d/Makefile" 2>/dev/null; then
    ROOT="$d"
    break
  fi
done

# 如果候选路径没找到，再用 find（控制深度避免太慢）
if [ -z "$ROOT" ]; then
  for mf in $(find / -maxdepth 5 -name Makefile 2>/dev/null || true); do
    if grep -q "^image:" "$mf" 2>/dev/null; then
      ROOT=$(dirname "$mf")
      break
    fi
  done
fi

if [ -z "$ROOT" ]; then
  echo "ERROR: 未能找到包含 image: 目标的 Makefile —— 无法确定 ImageBuilder 根目录。"
  echo "请确认所用 imagebuilder 镜像以及镜像内部路径，或在此脚本中添加候选目录。"
  exit 1
fi

echo "Found OpenWRT root: $ROOT"
cd "$ROOT"

# 将外部 build.sh 拷贝到 root 并执行（保证 .config 等写入的是正确位置）
cp /builder/build.sh ./build.sh
chmod +x ./build.sh

# 确保外部挂载的 files 路径是 /builder/files（build.sh 中若使用相对 files，请改为 FILES=/builder/files）
# 我们直接运行 build.sh；若需要可改为: FILES=/builder/files ./build.sh
./build.sh
'

