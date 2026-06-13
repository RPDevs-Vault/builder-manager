# 📦 container-manager

### 📦 [Organization Packages](https://github.com/orgs/RPDevs-Vault/packages)

Central hub for managing GitHub Container Registry (GHCR) assets for the **RPDevs Vault** organization.

## 🏗️ Structure

- **`/build/`**: Subdirectories here containing a `Dockerfile` are automatically built and pushed to GHCR as `ghcr.io/rpdevs-vault/<dir-name>`.
- **`/compose/`**: Central store for Docker Compose files.
- **`/images/`**: Source of truth for personal/custom Docker image definitions.
- **`/containers/`**: Deployment configurations, including one-liner Docker commands.
- **`manifest.yaml`**: Central registry of all containerized projects and build parameters.

## 🚀 Automation

- **[Container Build Engine](./.github/workflows/build-engine.yml):** Automatically builds and pushes any new subdirectories in `/build/` or `/images/` upon push to main.
- **[Docker Asset Collector](./.github/workflows/asset-collector.yml):** Weekly scan of all repositories in `IamRPDev` and `RPDevs-Vault` to identify and report on new `Dockerfiles` or `compose` files.
- **[GHCR Auditor](./.github/workflows/ghcr-auditor.yml):** Weekly report on existing organization packages.
- **[Stale Package Cleanup](./.github/workflows/stale-package-cleanup.yml):** Automatic pruning of untagged or old images.

---
*Part of the RPDevs Vault Command Center.*
