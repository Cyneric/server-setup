#!/bin/bash
# @Title: Login Script
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Description: Handles login notifications and system information display

# Source common utilities and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/config/settings.local.sh"
source "${SCRIPT_DIR}/config/settings.template.sh"

# System information collection
collect_system_info() {
    local user_info="$(id -u -n)"
    local ip_info="$(echo $SSH_CLIENT | awk '{ print $1}')"
    local host_info="$(hostname --short)"
    local host_ip="$(hostname -I | awk '{print $1}')"

    echo "${user_info}|${ip_info}|${host_info}|${host_ip}"
}

# Gotify notification handling with retry
send_notification() {
    # Only proceed if notifications are enabled
    if [[ "${ENABLE_NOTIFICATIONS}" != "true" ]]; then
        return 0
    fi

    local system_info="$1"
    local IFS='|'
    read -r user ip host host_ip <<<"$system_info"
    local max_retries=3
    local retry_count=0

    local title="Connection Established"
    local message="[${user}] [${ip}] connected to [${HOST}] [${HOSTIP}]"

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
    # Only send notification if enabled
    if [[ "${ENABLE_NOTIFICATIONS}" == "true" ]]; then
        local system_info="$(collect_system_info)"
        send_notification "$system_info"
    fi

    # Only show MOTD if it hasn't been shown in this session
    if [[ ! -f "/tmp/.motd_shown_${USER}" ]]; then
        echo -e "$MOTD"
        touch "/tmp/.motd_shown_${USER}"
    fi

    # Show system information if available
    if command -v neofetch >/dev/null; then
        neofetch
    elif command -v screenfetch >/dev/null; then
        screenfetch
    fi

    if command -v duf >/dev/null; then
        duf --only local
    fi
}

main "$@"
