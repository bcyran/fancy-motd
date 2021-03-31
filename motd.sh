#!/usr/bin/env bash

# Don't change! We want predictable outputs
export LANG="en_US.UTF-8"

# Dir of this scrip
export BASE_DIR="$(dirname "$(readlink -f "$0")")"

# Source the framework
source "$BASE_DIR/framework.sh"

# Run the modules and collect output
output=""
modules="$(ls -1 "$BASE_DIR/modules")"
while read -r module; do
    module_output="$($BASE_DIR/modules/$module 2>/dev/null)"
    [ $? -ne 0 ] && continue
    output+="$module_output"
    [ -n "$module_output" ] && output+=$'\n'
done <<< $modules

# Print the output in pretty columns
columnize "$output" $'\t' $'\n'
