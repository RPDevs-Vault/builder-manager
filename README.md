# 🔨 Builder Manager — Tier 2-2.5: Build & Cache Engine

Welcome to the **Builder Manager**, the unified orchestration engine for building, caching, and releasing cross-platform dependencies, custom OCI container images, and runner build layers across the RPDevs ecosystem.

This repository consolidates two legacy modules:
1. `container-manager` (OCI container compilation, base runner images, and registry tags auditing).
2. `dependency-manager` (weekly dependency scanning, package caches warmups, and pre-built binaries compiling).

---

## 🏛️ Directory Structure & Layout

The repository is organized into two primary pillars:

```
├── .github/workflows/         # GHA workflows (base images, scans, and collector engines)
├── container/                 # Container Compilation & Registry (Legacy container-manager)
│   ├── containers/            # Custom Dockerfiles and build recipes per project
│   ├── dependencies/          # Libraries/depends compilation recipes (e.g. Kodi depends)
│   ├── images/                # Markdown catalogs tracking container targets and images
│   ├── runners/               # Specialized Docker base files for self-hosted runner nodes
│   ├── manifest.yaml          # Global manifest listing active OCI compilation targets
│   └── exclusion_list.md      # Paths excluded from automated indexing and processing
└── dependency/                # Dependency & Cache Orchestration (Legacy dependency-manager)
    ├── scan_dependencies.py   # Organization-wide dependency scraper script
    ├── dependency_registry.json # Compiled registry catalog mapping repositories to languages
    └── README.md              # Registry specific manual execution details
```

---

## ⚙️ Core Build Workflows

All automated processes are executed via GitHub Action workflows located in `.github/workflows/`:

| Workflow File | Trigger Condition | Role / Process |
| :--- | :--- | :--- |
| **`base-image-builder.yml`** | Manual or push to `/container/runners/**` | Compiles and publishes the specialized base runner images (`runner-multiarch-builder`) used by our self-hosted runner fleets. |
| **`build-engine.yml`** | Repository Dispatch (`collect_docker_assets`) | Automatically compiles individual OCI images defined under `/container/containers/` and publishes them to GitHub Container Registry (GHCR). |
| **`warmup-caches.yml`** | Weekly or Manual | Triggers weekly jobs on self-hosted runners to warm up package cache volumes for **NPM**, **Go**, **Cargo**, and **Python Pip/Poetry**. |
| **`registry-manager.yml`** | Scheduled, Dispatch, or Push | A unified engine that handles dependency compilation, organization dependency scanning, GHCR auditing, OCI image mirroring, stale package pruning, and docker asset collection. |
| **`kodi-build-release.yml`** | Manual, Push, Pull Request | Compiles and packages Kodi release builds for Linux, Windows, and Android, utilizing high-speed NFS caching via Cloudflare Tunnel. |
| **`kodi-build-depends.yml`** | Manual, Schedule | Compiles and packages Kodi build dependencies (e.g., for macOS and Android) and publishes them as GitHub releases. |
| **`kodi-hybrid-router.yml`** | Workflow Call | Reusable routing workflow to dynamically determine the optimal runner tier for Kodi builds (hosted vs self-hosted). |

---

## 🚀 Execution & Operational Guide

### 1. Running the Dependency Scanner Locally
The organization-wide dependency scanner can be triggered manually from the repository root:
```bash
# Automatically uses your authenticated GitHub CLI token
GH_TOKEN=$(gh auth token) python3 dependency/scan_dependencies.py
```
This script queries both `RPDevs-Builds` and `RPDevs-Vault` organizations, scans all repositories for files like `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `addon.xml`, and writes the compiled registry database to `dependency/dependency_registry.json`.

### 2. Custom Container Build Configuration
To define a new build target:
1. Create a subdirectory under `container/containers/RPDevs-Vault_<name>` or `container/containers/<name>`.
2. Add a `Dockerfile`, a `README.md` documenting the image name, and a `command.txt` detailing the runtime command.
3. Register the target inside `container/manifest.yaml`:
   ```yaml
   projects:
     - name: new-service
       source_url: https://github.com/RPDevs-Vault/new-service.git
       branch: main
       platforms: [linux/amd64, linux/arm64]
   ```
4. Push the changes to trigger the automated build pipelines.

---

## 📦 Shared Caching & Warmup Heuristics

To accelerate CI/CD workflows across our `llmadmin01` and `T430` self-hosted runner fleets, the runner containers mount dedicated local volume caches:
* **Pip Cache**: `/mnt/sharedroot/github_runners/shared/pip-cache` -> `/home/runner/.cache/pip`
* **Poetry Cache**: `/mnt/sharedroot/github_runners/shared/poetry-cache` -> `/home/runner/.cache/pypoetry`
* **Ccache**: Shared build files cached over NFS to accelerate native C/C++ builds (like Kodi depends).

The `warmup-caches.yml` workflow guarantees that common base packages and dependencies are pre-indexed and populated weekly to eliminate download overhead during core runs.
