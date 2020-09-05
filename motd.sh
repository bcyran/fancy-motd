#!/usr/bin/env bash

# Colors
export CA="\e[34m"  # Accent
export CO="\e[32m"  # Ok
export CW="\e[33m"  # Warning
export CE="\e[31m"  # Error
export CN="\e[0m"   # None

# Run all scripts and align output in columns
run-parts modules | column -s $'\t' -t
