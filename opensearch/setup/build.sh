#!/usr/bin/env bash

set -eu

sudo apt-get update

sudo apt-get install python3-pip python3-venv -y --no-install-recommends
python3 -m pip install --user pipx
python3 -m pipx ensurepath

pipx inject poetry poetry-plugin-export
poetry config warnings.export false
pipx install charmcraftcache
