# RPDevs Vault - Hardened Base Alpine Image
FROM alpine:latest

# Install Fleet Standard Tooling
RUN apk add --no-cache \
    curl \
    git \
    jq \
    ca-certificates \
    build-base \
    bash \
    zip \
    unzip

# Install Fleet Management Tools (yq)
RUN VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r .tag_name) && \
    curl -L https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

LABEL maintainer="RPDevs Vault Command Center"
LABEL fleet.stability="v2"
