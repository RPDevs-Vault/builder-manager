# RPDevs Vault - Hardened Base Ubuntu Image
FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Fleet Standard Tooling
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    ca-certificates \
    build-essential \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Fleet Management Tools (yq)
RUN VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r .tag_name) && \
    curl -L https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

LABEL maintainer="RPDevs Vault Command Center"
LABEL fleet.stability="v2"
