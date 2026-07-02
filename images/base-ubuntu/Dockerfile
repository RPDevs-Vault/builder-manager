FROM ubuntu:24.04

# Set common labels
LABEL org.opencontainers.image.source="https://github.com/RPDevs-Vault/container-manager"
LABEL org.opencontainers.image.vendor="RPDevs-Vault"
LABEL org.opencontainers.image.title="base-ubuntu"

# Prevent interactive prompts during apt operations
ENV DEBIAN_FRONTEND=noninteractive

# Update packages, install certificates and tzdata
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        tzdata \
        curl \
        gosu && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create standard non-root user 'vault' with UID 1000
RUN groupadd -g 1000 vault && \
    useradd -u 1000 -g vault -m -s /bin/bash vault

# Set environment variables
ENV TZ=UTC
ENV HOME=/home/vault

CMD ["/bin/bash"]
