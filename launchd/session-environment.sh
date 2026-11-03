#!/bin/bash
# =====================================================================
# launchd/session-environment.sh - macOS Session Broadcaster
# =====================================================================

ENV_FILE="$HOME/.config/environment.d/session.conf"

if [[ ! -f "$ENV_FILE" ]]; then
    exit 1
fi

# 1. Source the file to populate the current shell's environment.
# This handles all the shell-escaping/quoting in the session.conf file.
source "$ENV_FILE"

# 2. Now, we iterate over the keys defined in the file to broadcast them via launchctl.
# We read the file line by line to identify which keys were actually set.
while IFS='=' read -r key _; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    
    # Clean the key (remove possible carriage returns or whitespace)
    clean_key=$(echo "$key" | tr -d '\r' | xargs)
    
    # Use indirect expansion to get the value that was just sourced
    # This is a bash-ism but we are in a bash script.
    value="${!clean_key}"
    
    if [[ -n "$clean_key" ]]; then
        launchctl setenv "$clean_key" "$value"
    fi
done < "$ENV_FILE"
