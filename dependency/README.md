# dependency-manager

This repository is the centralized manager for building, caching, and releasing cross-platform dependencies (Android, Linux, macOS/iOS, Windows) for the RPDevs ecosystem.

## Primary Workflows

### 1. Build and Archive Kodi Depends
* **Workflow**: `.github/workflows/build-depends.yml`
* **Description**: Rebuilds core dependencies weekly or on-demand, archiving them as GitHub releases and staging them to our shared fleet storage (`/mnt/sharedroot/github_runners/shared/appdata/kodi-depends`).

### 2. Scan Organizations for Dependencies
* **Workflow**: `.github/workflows/scan-dependencies.yml`
* **Script**: `scan_dependencies.py`
* **Description**: Weekly or manually triggers a scan across all repositories under the `RPDevs-Builds` and `RPDevs-Vault` organizations. It checks the default branch roots for key dependency files (e.g., `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `addon.xml`, `Dockerfile`).

## Dependency Registry
All identified repositories and their respective dependency files are saved to:
* **File**: `dependency_registry.json` (at the root of this repository)

This file acts as the single source of truth for the dependency manager and other fleet orchestration systems to schedule compilation, pre-building, and caching jobs.

