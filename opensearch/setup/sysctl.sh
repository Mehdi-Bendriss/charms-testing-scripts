#!/usr/bin/env bash

set -eu

# Define the lines to be added
lines=("vm.max_map_count=262144" "vm.swappiness=0" "net.ipv4.tcp_retries2=5" "fs.file-max=1048576")

# Loop through each line
for line in "${lines[@]}"; do
    # Check if the line is already in the file, if not, append it
    grep -qxF "${line}" /etc/sysctl.conf || echo "${line}" | sudo tee -a /etc/sysctl.conf > /dev/null
done

sudo sysctl -p
