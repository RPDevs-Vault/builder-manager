# Kodi-Fleet Linux Builder Runner (Thin Image)
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
    ninja-build \
    rsync \
    patch \
    wget \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Latest CMake from Kitware (Required for --modify flag support)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
    apt-get update && apt-get install -y cmake && \
    rm -rf /var/lib/apt/lists/*

# Pre-install ALL Kodi C++ build dependencies (Native Libraries)
RUN apt-get update && apt-get install -y \
    autoconf automake autopoint gettext libtool libtool-bin gawk gperf bison flex groff \
    python3-setuptools \
    libudev-dev libdrm-dev libgbm-dev libasound2-dev libpulse-dev libva-dev libvdpau-dev libxml2-dev libxslt1-dev \
    libsqlite3-dev libcurl4-openssl-dev libssl-dev libbluray-dev libcdio-dev libiso9660-dev liblzo2-dev libpcre3-dev \
    libmysqlclient-dev libcap-dev libfribidi-dev libfontconfig1-dev libfreetype6-dev libass-dev \
    libdbus-1-dev libsystemd-dev libavahi-client-dev libavahi-common-dev libmicrohttpd-dev libtinyxml-dev \
    libyajl-dev libplist-dev libnfs-dev libshairplay-dev libsmbclient-dev libfmt-dev libspdlog-dev libflatbuffers-dev \
    libx11-dev libxext-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libxrender-dev libxss-dev libgl1-mesa-dev \
    libexiv2-dev libdav1d-dev nasm meson swig \
    libgtest-dev clang-format libfstrcmp-dev \
    libwayland-dev libinput-dev libxkbcommon-dev waylandpp-dev \
    libvulkan-dev libegl1-mesa-dev libgles2-mesa-dev hwdata \
    libgif-dev libjpeg-dev \
    # Build Tools
    mingw-w64 \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    && rm -rf /var/lib/apt/lists/*

# Build wayland-protocols from source (Ubuntu 22.04 version is too old for latest Kodi)
RUN git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git && \
    cd wayland-protocols && git checkout 1.36 && \
    meson setup build && ninja -C build install && \
    cd .. && rm -rf wayland-protocols

# Build libdisplay-info from source (Not available in Ubuntu 22.04)
RUN git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git && \
    cd libdisplay-info && meson setup build && ninja -C build install && \
    cd .. && rm -rf libdisplay-info

# Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y \
    && rm -rf /var/lib/apt/lists/*

# Add a non-root user for the runner
RUN useradd -m runner && \
    usermod -aG sudo runner && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Download and install the GitHub Runner agent
WORKDIR /home/runner
ARG RUNNER_VERSION=2.335.1
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install runner dependencies
RUN ./bin/installdependencies.sh

# Environment Setup for Dynamic SDKs
ENV ANDROID_HOME=/home/runner/shared/appdata/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

# Set up entrypoint for auto-configuration
COPY entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh

# Pre-create directories that Docker would otherwise create as root for bind-mounts.
# This prevents permission errors for Go build cache, runner toolchain cache, etc.
RUN mkdir -p /home/runner/.cache /home/runner/_work /home/runner/go && \
    chown -R runner:runner /home/runner/.cache /home/runner/_work /home/runner/go

USER runner
ENTRYPOINT ["/home/runner/entrypoint.sh"]
