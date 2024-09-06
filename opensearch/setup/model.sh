#!/usr/bin/env bash

set -eu

model_name=""


# Args handling
function parse_args() {
    local LONG_OPTS_LIST=(
        "name"
    )
    # shellcheck disable=SC2155
    local opts=$(getopt \
      --longoptions "$(printf "%s:," "${LONG_OPTS_LIST[@]}")" \
      --name "$(readlink -f "${BASH_SOURCE}")" \
      --options "" \
      -- "$@"
    )
    eval set -- "${opts}"

    while [ $# -gt 0 ]; do
        case $1 in
            --name) shift
                model_name=$1
                ;;
        esac
        shift
    done
}

parse_args "$@"


# cloud init
cat <<EOF > cloudinit-userdata.yaml
cloudinit-userdata: |
  postruncmd:
    - [ 'echo', 'vm.max_map_count=262144', '>>', '/etc/sysctl.conf' ]
    - [ 'echo', 'vm.swappiness=0', '>>', '/etc/sysctl.conf' ]
    - [ 'echo', 'net.ipv4.tcp_retries2=5', '>>', '/etc/sysctl.conf' ]
    - [ 'echo', 'fs.file-max=1048576', '>>', '/etc/sysctl.conf' ]
    - [ 'sysctl', '-p' ]
EOF


# Model creation
juju destroy-model --no-prompt "${model_name}" --no-wait --force --destroy-storage --no-prompt --timeout 0 || true

juju add-model "${model_name}"

juju model-config logging-config="<root>=INFO;unit=DEBUG"
juju model-config update-status-hook-interval=5m
juju model-config --file=./cloudinit-userdata.yaml
