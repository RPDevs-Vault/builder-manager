# Master Dependency Inventory

This document tracks all pre-compiled toolchains and dependencies hosted for the RPDevs-Vault build fleet. By centrally managing these dependencies, we bypass the need for lengthy full-source compilations across individual container and software builds.

## Software Inventory

| Dependency Package | Dependent Software / Projects | Architecture Targets | Status |
|--------------------|-----------------------------|----------------------|--------|
| **Kodi Toolchain** | `xbmc`, `rvx-builds`, Addon Builders | `linux-x86_64`, `linux-arm64`, `android-arm64` | Active |

*(Add new dependencies here as they are onboarded to the fleet)*

## Automation
These dependencies are built and packaged automatically by the `dependency-engine.yml` GitHub Actions workflow. Output artifacts are published as GitHub Releases and can be fetched dynamically during dependent builds.
