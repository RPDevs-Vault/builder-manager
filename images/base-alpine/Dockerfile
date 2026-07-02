FROM alpine:latest

# Set common labels
LABEL org.opencontainers.image.source="https://github.com/RPDevs-Vault/container-manager"
LABEL org.opencontainers.image.vendor="RPDevs-Vault"
LABEL org.opencontainers.image.title="base-alpine"

# Update packages, install certificates and tzdata
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ca-certificates tzdata su-exec && \
    rm -rf /var/cache/apk/*

# Create standard non-root user 'vault' with UID 1000
RUN addgroup -g 1000 vault && \
    adduser -u 1000 -G vault -h /home/vault -D vault

# Set environment variables
ENV TZ=UTC
ENV HOME=/home/vault

CMD ["/bin/sh"]
