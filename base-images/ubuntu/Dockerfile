FROM ubuntu:24.04

# Prevent interactive prompts during apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install base certificates and timezone data
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        tzdata \
        curl && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates

# Create a non-root user for security (clean up pre-existing user ubuntu with UID 1000 first)
RUN userdel -r ubuntu || true && \
    groupdel ubuntu || true && \
    groupadd -g 1000 rpdevs && \
    useradd -u 1000 -g rpdevs -m -s /bin/bash rpdevs

USER rpdevs
WORKDIR /home/rpdevs
