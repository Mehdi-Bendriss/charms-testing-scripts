#!/usr/bin/env bash

set -eu

SCRIPTS="$(dirname "${BASH_SOURCE[0]}")/setup"

bash "${SCRIPTS}/build.sh"
bash "${SCRIPTS}/sysctl.sh"
bash "${SCRIPTS}/model.sh" --name "dev0"
source "${SCRIPTS}/model.sh" --name "dev1"
source "${SCRIPTS}/model.sh" --name "dev2"

tox run -e build-dev

# ------- deploying on model :dev0 --------
juju switch :dev0

juju deploy -n 1 \
    self-signed-certificates \
    --config ca-common-name="CN_CA" \
    --channel stable --series jammy --show-log --verbose

juju deploy -n 3 \
    ./opensearch_ubuntu-22.04-amd64.charm \
    main \
    --config cluster_name="log-app" --config init_hold="false" \
    --series jammy --show-log --verbose

juju offer self-signed-certificates:certificates
juju offer main:peer-cluster-orchestrator

juju integrate self-signed-certificates main


# ------ deploying on model :dev1 ------
juju switch :dev1
juju deploy -n 3 \
    ./opensearch_ubuntu-22.04-amd64.charm \
    failover \
    --config cluster_name="log-app" --config init_hold="true" \
    --series jammy --show-log --verbose

juju consume admin/dev0.self-signed-certificates
juju consume admin/dev0.main
juju offer failover:peer-cluster-orchestrator

juju integrate self-signed-certificates failover


# ------ deploying on model :dev2 ------
juju switch :dev2
juju deploy -n 2 \
    ./opensearch_ubuntu-22.04-amd64.charm \
    data \
    --config cluster_name="log-app" --config init_hold="true" --config roles="data.hot" \
    --series jammy --show-log --verbose

juju deploy -n 1 \
    ./opensearch_ubuntu-22.04-amd64.charm \
    ml \
    --config cluster_name="log-app" --config init_hold="true" --config roles="ml" \
    --series jammy --show-log --verbose

juju consume admin/dev0.self-signed-certificates
juju consume admin/dev0.main
juju consume admin/dev1.failover

juju integrate self-signed-certificates data
juju integrate self-signed-certificates ml