#!/usr/bin/env bash

# Don't change! We want predictable outputs
export LANG="en_US.UTF-8"

# Dir of this scrip
BASE_DIR=$(dirname "$(readlink -f "$0")")
export BASE_DIR

# Set config path
if [[ -z ${1+x} ]]; then
    export CONFIG_PATH="${BASE_DIR}/config.sh"
else
    export CONFIG_PATH="$1"
fi

# Source the framework
source "${BASE_DIR}/framework.sh"

# Run the modules and collect output
output=""
# shellcheck disable=SC2010
modules="$(ls -1 "${BASE_DIR}/modules" | grep -P '^(?<!\d)\d{2}(?!\d)-')"
while read -r module; do
    if ! module_output=$("${BASE_DIR}/modules/${module}" 2> /dev/null); then continue; fi
    output+="${module_output}"
    [[ -n "${module_output}" ]] && output+=$'\n'
done <<< "${modules}"

# Print the output in pretty columns
columnize "${output}" $'\t' $'\n'
