#!/usr/bin/env bash

set -eu

DEPLOYMENT_TYPE="simple"
PROJECT=""


# Args handling
function parse_args() {
    local LONG_OPTS_LIST=(
        "type"
        "project"
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
            --type) shift
                DEPLOYMENT_TYPE=$1
                ;;
            --project) shift
                PROJECT=$1
                ;;
        esac
        shift
    done
}

parse_args "$@"

CURRENT_DIR="${PWD}"
cd "${PROJECT}" || exit 1

if [[ "${DEPLOYMENT_TYPE}" = "large" ]]; then
    source "${CURRENT_DIR}"/large-deployments.sh
else
    source "${CURRENT_DIR}"/simple-deployments.sh
fi

cd "${CURRENT_DIR}" || exit 1
