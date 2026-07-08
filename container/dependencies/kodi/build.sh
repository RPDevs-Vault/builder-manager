#!/bin/bash
set -e

# Kodi Dependency Build Script
# Executed by dependency-engine.yml to pre-compile Kodi dependencies.
# Usage: ./build.sh <platform> <host_triplet> <kodi_branch>
#   platform:     linux | android
#   host_triplet: x86_64-linux-gnu | aarch64-linux-gnu | aarch64-linux-android
#   kodi_branch:  master | Piers | Omega

PLATFORM=${1:-linux}
HOST_TRIPLET=${2:-x86_64-linux-gnu}
KODI_BRANCH=${3:-master}

echo "=== Kodi Dependency Builder ==="
echo "  Platform:    $PLATFORM"
echo "  Host:        $HOST_TRIPLET"
echo "  Branch:      $KODI_BRANCH"
echo ""

# 1. Clone Kodi source (shallow)
if [ ! -d "xbmc" ]; then
  git clone --branch "$KODI_BRANCH" --depth 1 https://github.com/xbmc/xbmc.git
fi

cd xbmc/tools/depends

# 2. Configure ccache if available
if command -v ccache >/dev/null 2>&1 && [ -n "$CCACHE_DIR" ]; then
  echo "Enabling ccache (CCACHE_DIR=$CCACHE_DIR)"
  export CC="ccache gcc"
  export CXX="ccache g++"
  ccache -z
  ccache -s
fi

# 3. Apply Apple-specific patches
if [[ "$PLATFORM" == "osx64" || "$PLATFORM" == "ios" || "$PLATFORM" == "tvos" ]]; then
  echo "Applying Darwin kernel version and ASM patches..."
  sed -i '' 's/$(MAKE) -C $(PLATFORM)/mkdir -p $(PLATFORM)\/src\/syscfg \&\& cp -v $(PLATFORM)\/src\/syscfg\/lock-obj-pub.aarch64-apple-darwin.h $(PLATFORM)\/src\/syscfg\/lock-obj-pub.darwin24.6.0.h || true \&\& $(MAKE) -C $(PLATFORM)/' target/libgpg-error/Makefile || true
  sed -i '' 's/$(CONFIGURE)/$(CONFIGURE) --disable-asm/' target/libgcrypt/Makefile || true
  sed -i '' 's/export LIBS=.*/export LIBS=$(LINK_ICONV) -lintl/' target/python3/Makefile || true
fi

# 4. Bootstrap
./bootstrap

# 5. Build platform-specific configure flags
PREFIX_DIR="$(pwd)/../../../../compiled-artifacts"
mkdir -p "$PREFIX_DIR"

CONFIG_FLAGS="--prefix=$PREFIX_DIR --host=$HOST_TRIPLET"

case "$PLATFORM" in
  linux)
    CONFIG_FLAGS="$CONFIG_FLAGS --with-rendersystem=gl"
    ;;
  android)
    # Android SDK/NDK paths match the runner-linux-builder Dockerfile
    SDK_PATH="${ANDROID_HOME:-/opt/android-sdk}"
    NDK_VERSION=$(ls "$SDK_PATH/ndk/" 2>/dev/null | head -n 1)
    NDK_PATH="$SDK_PATH/ndk/${NDK_VERSION}"

    if [ ! -d "$NDK_PATH" ]; then
      echo "ERROR: Android NDK not found at $NDK_PATH"
      echo "Available NDK versions: $(ls "$SDK_PATH/ndk/" 2>/dev/null || echo 'none')"
      exit 1
    fi

    echo "Using Android SDK: $SDK_PATH"
    echo "Using Android NDK: $NDK_PATH"
    CONFIG_FLAGS="$CONFIG_FLAGS --with-platform=android --with-sdk-path=$SDK_PATH --with-ndk-path=$NDK_PATH"
    ;;
  osx64)
    CONFIG_FLAGS="$CONFIG_FLAGS --with-platform=macos"
    ;;
  *)
    CONFIG_FLAGS="$CONFIG_FLAGS --with-platform=$PLATFORM"
    ;;
esac

echo "Configure flags: $CONFIG_FLAGS"
./configure $CONFIG_FLAGS

# 6. Build with all available cores
make -j$(nproc || sysctl -n hw.ncpu)

# 7. Report ccache stats
if command -v ccache >/dev/null 2>&1 && [ -n "$CCACHE_DIR" ]; then
  echo ""
  echo "=== ccache statistics ==="
  ccache -s
fi

echo ""
echo "=== Build Complete ==="
echo "Toolchain location: $PREFIX_DIR"
