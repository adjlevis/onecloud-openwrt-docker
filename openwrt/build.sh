#!/bin/bash
set -e

echo "📥 开始下载预构建 rootfs..."
ROOTFS_URL="https://dl.openwrt.ai/releases/targets/amlogic/meson8b/kwrt-10.30.2025-amlogic-meson8b-thunder-onecloud-rootfs.tar.gz"

mkdir -p bin/rootfs files release/openwrt

cd bin/rootfs
curl -LO "$ROOTFS_URL"
cd ../..

echo "✅ rootfs 下载完成。"

echo "📂 解压 rootfs 到 files/..."
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

echo "📦 打包固件..."
tar -czf release/openwrt/thunder-onecloud-custom-rootfs.tar.gz -C files/ .

echo "✅ 打包完成: release/openwrt/thunder-onecloud-custom-rootfs.tar.gz"
