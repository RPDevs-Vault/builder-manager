# Master Dependency Inventory

This document tracks all pre-compiled toolchains and dependencies hosted for the RPDevs-Vault build fleet. By centrally managing these dependencies, we bypass the need for lengthy full-source compilations.

## Software Inventory

| Dependency Package | Dependent Software / Projects | Architecture Targets | Status |
|--------------------|-----------------------------|----------------------|--------|
| **Kodi Toolchain** | `xbmc`, `rvx-builds` | `linux-x86_64`, `linux-arm64` | Active |
| **FlareSolverr**   | `FlareSolverr`              | `linux/amd64`, `arm64` | Active |
| **mega-embed-2**   | `mega-embed-2`              | `linux/amd64`, `arm64` | Active |
| **t430-runner**    | `T430-Runner`               | `linux/amd64`        | Active |

## Automation
Dependencies are managed under `dependencies/<software-name>/` and automated via the `dependency-engine.yml` workflow.
