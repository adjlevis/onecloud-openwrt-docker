#!/bin/bash
set -e

ROOTFS_URL="https://dl.openwrt.ai/releases/targets/amlogic/meson8b/kwrt-10.30.2025-amlogic-meson8b-thunder-onecloud-rootfs.tar.gz"
OUTPUT_DIR="release/openwrt"
WORK_DIR="$(pwd)"

echo "📥 下载预构建 rootfs..."
mkdir -p bin/rootfs files "$OUTPUT_DIR"

cd bin/rootfs
curl -LO "$ROOTFS_URL"
cd "$WORK_DIR"

echo "✅ rootfs 下载完成"

echo "📂 解压 rootfs..."
tar -xzf bin/rootfs/*.tar.gz -C files/ || true

echo "🧰 写入旁路由网络配置..."
mkdir -p files/etc/config

cat <<'NETCONF' > files/etc/config/network
config interface 'lan'
  option proto 'static'
  option ipaddr '192.168.2.2'
  option netmask '255.255.255.0'
  option gateway '192.168.2.1'
  option dns '192.168.2.1'
NETCONF

cat <<'DHCP' > files/etc/config/dhcp
config dhcp 'lan'
  option ignore '1'
DHCP

echo "✅ 已配置为旁路由 (IP=192.168.2.2, 网关=192.168.2.1, DHCP=关闭)"

# ==============================
# 🔧 制作 EXT4 镜像（线刷用）
# ==============================
IMG_FILE="${OUTPUT_DIR}/thunder-onecloud-emmc-ext4.img"
MNT_DIR="./mnt_ext4"

echo "🧱 创建 EXT4 镜像文件..."
IMG_SIZE_MB=512
dd if=/dev/zero of="$IMG_FILE" bs=1M count=$IMG_SIZE_MB status=progress

echo "⚙️ 格式化为 EXT4..."
mkfs.ext4 -F "$IMG_FILE"

echo "📦 挂载镜像并写入 rootfs..."
sudo mkdir -p "$MNT_DIR"
sudo mount -o loop "$IMG_FILE" "$MNT_DIR"
sudo rsync -aHAX files/ "$MNT_DIR"/

sync
sudo umount "$MNT_DIR"
sudo rm -rf "$MNT_DIR"

echo "✅ EXT4 镜像制作完成: $IMG_FILE"

# 可选：压缩镜像节省空间
echo "📦 压缩镜像..."
gzip -f "$IMG_FILE"
echo "✅ 输出文件: ${IMG_FILE}.gz"
