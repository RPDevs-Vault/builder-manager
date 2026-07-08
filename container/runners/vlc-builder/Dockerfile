# VLC Linux Builder Runner
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies and CI tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    sudo \
    build-essential \
    ca-certificates \
    libicu-dev \
    python3 \
    python3-pip \
    python3-dev \
    zip \
    unzip \
    tar \
    ccache \
    cmake \
    ninja-build \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Install VLC-specific build dependencies
RUN apt-get update && apt-get install -y \
    autoconf automake libtool gettext pkg-config \
    flex bison lua5.2 liblua5.2-dev libmad0-dev libavcodec-dev \
    libavformat-dev libswscale-dev libpostproc-dev liba52-0.7.4-dev \
    libmpeg2-4-dev libvorbis-dev libogg-dev libtheora-dev libshout3-dev \
    libspeex-dev libtwolame-dev libx264-dev libva-dev libdrm-dev \
    libxcb1-dev libxcb-shm0-dev libxcb-xv0-dev libxcb-keysyms1-dev \
    libxcb-randr0-dev libxcb-composite0-dev libxcb-render0-dev \
    libxcb-image0-dev libxcb-util0-dev libxcb-xkb-dev libxkbcommon-x11-dev \
    libasound2-dev libpulse-dev libdbus-1-dev libidn11-dev \
    # Additional common tools
    gawk gperf autopoint mingw-w64 gcc-arm-linux-gnueabi g++-arm-linux-gnueabi gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
    && rm -rf /var/lib/apt/lists/*

# Add a non-root user for the runner
RUN useradd -m runner && \
    usermod -aG sudo runner && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Download and install the GitHub Runner agent
WORKDIR /home/runner
ARG RUNNER_VERSION=2.317.0
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install runner dependencies
RUN ./bin/installdependencies.sh

# Set up entrypoint for auto-configuration
COPY entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh

USER runner
ENTRYPOINT ["/home/runner/entrypoint.sh"]
