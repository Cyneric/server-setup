#!/bin/bash
# @Title: Logout Script
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Description: Handles logout notifications

# Source common utilities and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/config/settings.local.sh"

send_logout_notification() {
    local user="$1"
    local ip="$2"
    local host="$3"
    local hostip="$4"
    local max_retries=3
    local retry_count=0

    local title="Connection Closed"
    local message="[${user}] [${ip}] disconnected from [${host}] [${hostip}]"

    if [[ -n "${GOTIFY_URL}" && -n "${GOTIFY_TOKEN}" ]]; then
        while [ $retry_count -lt $max_retries ]; do
            if curl -s --data "{\"message\": \"${message}\", \"title\": \"${title}\", \"priority\": 5}" \
                -H 'Content-Type: application/json' \
                "${GOTIFY_URL}?token=${GOTIFY_TOKEN}" >/dev/null; then
                return 0
            fi
            retry_count=$((retry_count + 1))
            sleep 1
        done
        log_warning "Failed to send Gotify notification after $max_retries attempts"
    fi
}

main() {
    local USER=$(id -u -n)
    local IP=$(echo $SSH_CLIENT | awk '{ print $1}')
    local HOST=$(hostname --short)
    local HOSTIP=$(hostname -I | awk '{print $1}')

    send_logout_notification "$USER" "$IP" "$HOST" "$HOSTIP"

    # Cleanup session files
    rm -f "/tmp/.motd_shown_${USER}"
}

main "$@"
