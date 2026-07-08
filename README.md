# dependency-manager

This repository is the centralized manager for building, caching, and releasing cross-platform dependencies (Android, Linux, macOS/iOS, Windows) for the RPDevs ecosystem.

## Primary Workflows
* **Build and Archive Kodi Depends**: `.github/workflows/build-depends.yml` - Rebuilds core dependencies weekly or on-demand, archiving them as GitHub releases and staging them to our shared fleet storage (`/mnt/sharedroot/github_runners/shared/appdata/kodi-depends`).
