#!/bin/bash

# --- SDK & Toolchain Staging ---
# Path: /home/runner/shared/appdata (Centralized under github_runners/shared)
SHARED_APP_DIR="/home/runner/shared/appdata"

if [ -d "$SHARED_APP_DIR" ]; then
    echo "🔍 Found shared appdata. Provisioning toolchains..."

    # 1. Provision OpenJDK (Required for Android & Gradle)
    if sudo [ -f "$SHARED_APP_DIR/openjdk-17.tar.gz" ]; then
        if [ ! -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
            echo "📦 Extracting OpenJDK 17..."
            sudo mkdir -p /usr/lib/jvm
            sudo tar -xzf "$SHARED_APP_DIR/openjdk-17.tar.gz" -C /
        fi
    fi

    # 2. Provision Android SDK (Symlink from shared folder)
    if [ ! -d "/opt/android-sdk" ]; then
        if sudo [ -d "$SHARED_APP_DIR/android-sdk" ]; then
            echo "📦 Symlinking Android SDK from shared directory..."
            sudo ln -s "$SHARED_APP_DIR/android-sdk" /opt/android-sdk
        fi
    fi

    # 3. Provision Node.js
    if sudo [ -f "$SHARED_APP_DIR/nodejs-24.tar.gz" ]; then
        if ! command -v node &> /dev/null; then
            echo "📦 Extracting Node.js 24..."
            sudo tar -xzf "$SHARED_APP_DIR/nodejs-24.tar.gz" -C /
        fi
    fi

    # 4. Provision Kodi Depends based on Runner Labels
    for OS_TAG in "android-arm64" "osx64" "win64" "linux64" "linux-arm64" "ios" "tvos"; do
        if [[ "${RUNNER_LABELS:-}" == *"$OS_TAG"* ]]; then
            DEPENDS_TAR="$SHARED_APP_DIR/kodi-depends/$OS_TAG/depends.tar.gz"
            if sudo [ -f "$DEPENDS_TAR" ]; then
                echo "📦 Auto-provisioning Kodi Depends for: $OS_TAG"
                sudo mkdir -p /opt/xbmc-deps
                sudo tar -xzf "$DEPENDS_TAR" -C /opt/xbmc-deps
                sudo chown -R runner:runner /opt/xbmc-deps
                export KODI_DEPENDS_PATH=/opt/xbmc-deps
            fi
        fi
    done
fi

# --- GitHub Runner Registration ---
if [ -n "${GH_REPOSITORY}" ]; then
    echo "Registering to Repository: ${GH_OWNER}/${GH_REPOSITORY}"
    REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq -r .token)
    URL="https://github.com/${GH_OWNER}/${GH_REPOSITORY}"
elif [ "${GH_TYPE}" == "user" ]; then
    echo "Registering to User Account: ${GH_OWNER}"
    REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GH_TOKEN}" https://api.github.com/user/actions/runners/registration-token | jq -r .token)
    URL="https://github.com/${GH_OWNER}"
else
    echo "Registering to Organization: ${GH_OWNER}"
    REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GH_TOKEN}" https://api.github.com/orgs/${GH_OWNER}/actions/runners/registration-token | jq -r .token)
    URL="https://github.com/${GH_OWNER}"
fi

./config.sh --url ${URL} --token ${REG_TOKEN} --name "${RUNNER_NAME:-custom-runner}" --labels "${RUNNER_LABELS:-linux64}" --runnergroup "${RUNNER_GROUP:-Default}" --unattended --replace

cleanup() {
    echo "Removing runner..."
    if [ -n "${GH_REPOSITORY}" ]; then
        REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq -r .token)
    elif [ "${GH_TYPE}" == "user" ]; then
        REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GH_TOKEN}" https://api.github.com/user/actions/runners/registration-token | jq -r .token)
    else
        REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GH_TOKEN}" https://api.github.com/orgs/${GH_OWNER}/actions/runners/registration-token | jq -r .token)
    fi
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
