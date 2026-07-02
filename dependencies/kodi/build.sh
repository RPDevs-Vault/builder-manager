#!/bin/bash
set -e

# Kodi Dependency Build Script
# This script is executed by the dependency-engine workflow to pre-compile Kodi dependencies.

PLATFORM=${1:-linux}
HOST_TRIPLET=${2:-x86_64-linux-gnu}
KODI_BRANCH=${3:-master}

echo "Building Kodi dependencies for PLATFORM: $PLATFORM, HOST: $HOST_TRIPLET, BRANCH: $KODI_BRANCH"

# 1. Clone Kodi
if [ ! -d "xbmc" ]; then
  git clone --branch "$KODI_BRANCH" --depth 1 https://github.com/xbmc/xbmc.git
fi

cd xbmc/tools/depends

# 2. Configure Depends System
# Using heuristics: explicit --with-platform and --host
PREFIX_DIR="$(pwd)/../../../../compiled-artifacts"
mkdir -p "$PREFIX_DIR"

# Enable ccache if available to speed up compilation
if command -v ccache >/dev/null 2>&1 && [ -n "$CCACHE_DIR" ]; then
  echo "Enabling ccache with CCACHE_DIR=$CCACHE_DIR"
  export CC="ccache gcc"
  export CXX="ccache g++"
  ccache -z
fi

./bootstrap
./configure --prefix="$PREFIX_DIR" --host="$HOST_TRIPLET" --with-platform="$PLATFORM"

# 3. Build Dependencies
# Using multiple cores
make -j$(nproc)

echo "Dependencies build complete. Toolchain is located at: $PREFIX_DIR"
