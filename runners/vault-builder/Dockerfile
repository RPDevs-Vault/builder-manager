# RPDevs Vault Build Fleet - General Purpose Build Runner
FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install core build and CI tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    sudo \
    build-essential \
    ca-certificates \
    zip \
    unzip \
    tar \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    python3-dev \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (to build images inside the runner)
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Pre-bake Management Tools (yq, gh)
RUN VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r .tag_name) && \
    curl -L https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y && \
    rm -rf /var/lib/apt/lists/*

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
