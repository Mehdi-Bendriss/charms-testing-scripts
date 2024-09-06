#!/usr/bin/env bash

set -eu

SCRIPTS="$(dirname "${BASH_SOURCE[0]}")/setup"

source "${SCRIPTS}/build.sh"
source "${SCRIPTS}/sysctl.sh"
source "${SCRIPTS}/model.sh" --name "dev"

tox run -e build-dev

# --------------- deploying ---------------
juju switch :dev

juju deploy -n 1 \
    self-signed-certificates \
    --config ca-common-name="CN_CA" \
    --channel stable --series jammy --show-log --verbose

juju deploy -n 3 \
    ./opensearch_ubuntu-22.04-amd64.charm \
    main \
    --config cluster_name="log-app" \
    --series jammy --show-log --verbose

# --------------- Integrations -------------
juju integrate self-signed-certificates main
