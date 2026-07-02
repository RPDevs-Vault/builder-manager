#!/bin/bash
# Registration Logic
# GH_OWNER is always the Org/User
# GH_TOKEN is required
# If GH_REPOSITORY is set, register to repo. Otherwise register to Org.

get_token() {
    local ENDPOINT=$1
    local RESPONSE=$(curl -sX POST -w "\n%{http_code}" -H "Authorization: token ${GH_TOKEN}" "$ENDPOINT")
    local HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    local BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" -ne 201 ]; then
        echo "ERROR: Failed to fetch registration token (HTTP $HTTP_CODE)."
        echo "Response: $BODY"
        echo "Sleeping for 60 seconds to prevent API abuse loops..."
        sleep 60
        exit 1
    fi

    echo "$BODY" | jq -r .token
}

if [ -n "${GH_REPOSITORY}" ]; then
    echo "Registering to Repository: ${GH_OWNER}/${GH_REPOSITORY}"
    REG_TOKEN=$(get_token "https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token")
    URL="https://github.com/${GH_OWNER}/${GH_REPOSITORY}"
else
    echo "Registering to Organization: ${GH_OWNER}"
    REG_TOKEN=$(get_token "https://api.github.com/orgs/${GH_OWNER}/actions/runners/registration-token")
    URL="https://github.com/${GH_OWNER}"
fi

./config.sh --url ${URL} --token ${REG_TOKEN} --name "${RUNNER_NAME:-custom-runner}" --labels "${RUNNER_LABELS:-linux64}" --unattended --replace

cleanup() {
    echo "Removing runner..."
    if [ -n "${GH_REPOSITORY}" ]; then
        REG_TOKEN=$(get_token "https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token")
    else
        REG_TOKEN=$(get_token "https://api.github.com/orgs/${GH_OWNER}/actions/runners/registration-token")
    fi
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Dynamic GID mapping for Docker Socket
if [ -e /var/run/docker.sock ]; then
    DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
    sudo groupadd -g $DOCKER_GID docker_host || true
    sudo usermod -aG docker_host runner || true
fi

./run.sh & wait $!
