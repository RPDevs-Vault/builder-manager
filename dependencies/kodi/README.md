# Kodi Dependencies

This package contains the pre-compiled toolchain required to build Kodi (XBMC) from source.

## Dependent Software
- **Kodi (Mainline)**
- **Custom RPDevs-Vault Kodi Forks**
- **Kodi Addon Builders**

## Build Information
The toolchain is built using the `tools/depends` system within the Kodi source tree. It provides all necessary C++ libraries and cross-compilation headers for the target platforms (`linux-x86_64`, `linux-arm64`, and `android-arm64`).

## Usage
During your build phase, extract the corresponding release artifact into your build environment. Set the `CMAKE_PREFIX_PATH` to point to the extracted directory to allow Kodi's build system to locate these pre-compiled libraries, drastically reducing your build times.
