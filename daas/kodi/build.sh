#!/bin/bash
set -e

# Depends-as-a-Service (DaaS) - Kodi Build Script
# This script is executed by the daas-engine workflow to pre-compile Kodi dependencies.

PLATFORM=${1:-linux}
HOST_TRIPLET=${2:-x86_64-linux-gnu}
KODI_BRANCH=${3:-master}

echo "Building Kodi depends for PLATFORM: $PLATFORM, HOST: $HOST_TRIPLET, BRANCH: $KODI_BRANCH"

# 1. Clone Kodi
if [ ! -d "xbmc" ]; then
  git clone --branch "$KODI_BRANCH" --depth 1 https://github.com/xbmc/xbmc.git
fi

cd xbmc/tools/depends

# 2. Configure Depends System
# Using heuristics: explicit --with-platform and --host
# Prefix: $(pwd)/../../../../xbmc-deps
PREFIX_DIR="$(pwd)/../../../../xbmc-deps"
mkdir -p "$PREFIX_DIR"

./bootstrap
./configure --prefix="$PREFIX_DIR" --host="$HOST_TRIPLET" --with-platform="$PLATFORM"

# 3. Build Depends
# Using multiple cores
make -j$(nproc)

echo "Depends build complete. Toolchain is located at: $PREFIX_DIR"
