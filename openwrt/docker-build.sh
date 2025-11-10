#!/bin/bash
set -e

echo "启动 OpenWRT Docker 构建..."

docker run --rm \
  -v "$(pwd)/bin:/builder/bin" \
  -v "$(pwd)/files:/builder/files" \
  -v "$(pwd)/build.sh:/builder/build.sh" \
  openwrt/imagebuilder:armsr-armv7-master /builder/build.sh

