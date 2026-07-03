# 📦 Container Manager — Tier 2: Compilation & Fleet Builder

Welcome to the **container-manager** console. This repository serves as the Tier 2 Compilation Registry and asset builder, responsible for compiling OCI Docker images, hosting our custom builder base images, managing self-hosted runner caching systems, and mirroring packages to the GHCR registry.

* **Tier 0 Global Cockpit:** [github-manager](https://github.com/RPDevs-Vault/github-manager) (Live Health & Fleet Runners)
* **Tier 1 Governance Hub:** [vault-manager](https://github.com/RPDevs-Vault/vault-manager) (Policies & Dispatching)
* **Tier 3 Project Roadmap:** [project-manager](https://github.com/RPDevs-Vault/project-manager) (Task & Issue Sync)
* **Tier 4 Release Gateway:** [distributor-manager](https://github.com/RPDevs-Vault/distributor-manager) (Artifact Distribution)

---

## 🏗️ Structure

- **`/build/`**: Direct build folders. Subdirectories containing a `Dockerfile` are compiled and pushed to GHCR as `ghcr.io/rpdevs-vault/<dir-name>`.
- **`/compose/`**: Central store for Docker Compose files.
- **`/images/`**: Source of truth for custom Docker image definitions.
- **`/containers/`**: Repository of discovered Docker configurations, archived here to prevent automatic compilation loops until manually moved to `/build/` or listed in the manifest.
- **`manifest.yaml`**: The central registry defining remote projects to pull, build parameters, target platforms, and branch specifications.

## 🚀 Automation & Workflows

- **[Container Build Engine](./.github/workflows/build-engine.yml):** Builds and pushes subdirectories in `/build/`, `/images/`, `/runners/`, or projects registered in `manifest.yaml` upon pushes to `main`.
- **[Docker Asset Collector](./.github/workflows/docker-collector.yml):** Weekly scan of all repos in `IamRPDev` and `RPDevs-Vault` that discovers new `Dockerfiles` or `compose.yml` assets and archives them into `/containers/`.
- **[GHCR Auditor](./.github/workflows/ghcr-auditor.yml):** Weekly audit tracking package sizes, versions, and security metadata across the organization's GHCR namespace.
- **[Stale Package Cleanup](./.github/workflows/stale-package-cleanup.yml):** Prunes untagged images, old tags, and orphaned container layers.
- **[OCI Mirror](./.github/workflows/oci-mirror.yml):** Automatically mirrors upstream images directly to our GHCR namespace.

## 🔒 Self-Hosted Runner Infrastructure

The builder fleet operates on a hardened self-hosted infrastructure (`local-runner-01` on `llmadmin01` and `t430-lite-runner-01` on `t430`) utilizing:
- **Dynamic GID Mapping**: The runner container entrypoint (`runners/linux-builder/entrypoint.sh`) queries the GID of `/var/run/docker.sock` at boot, dynamically creating matching permissions internally. This allows sudo-less Docker execution securely.
- **NFS Local Build Cache**: Configured to mount and use `/mnt/sharedroot/docker-cache` for Docker Buildx caching. This speeds up consecutive compilation jobs and avoids standard 10GB runner limitations.
- **Concurrency Locks**: All critical workflows are protected by concurrency queues (`cancel-in-progress: false`) to serialize git commits and prevent branch pushes from overlapping.
- **Log Truncation**: Builds producing massive logs are captured into `build.log`, keeping GHA console output under 100 lines and saving the full file as a build artifact on failure.

---
*Part of the RPDevs Vault Command Center.*
