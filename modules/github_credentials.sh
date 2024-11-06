#!/bin/bash
# @Title: GitHub Credentials Provider
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Description: Fetches credentials from GitHub using Personal Access Token

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/utils.sh"

fetch_github_credentials() {
    local gh_token="$1"
    local config_file="$2"
    local repo_owner="Cyneric"
    local repo_name="shellscripts"
    local secret_names=("SSH_PUBLIC_KEY" "SYSLOG_IP" "SYSLOG_PORT" "GOTIFY_URL" "GOTIFY_TOKEN")

    # Check if GitHub CLI is installed
    if ! command -v gh &>/dev/null; then
        install_package gh
    fi

    # Authenticate with GitHub
    echo "$gh_token" | gh auth login --with-token

    # Create temporary JSON for building config
    local temp_json=$(mktemp)
    echo "{}" >"$temp_json"

    # Fetch each secret and build config JSON
    for secret in "${secret_names[@]}"; do
        local value=$(gh secret list -R "$repo_owner/$repo_name" | grep "^$secret" | cut -f1)
        if [[ -n "$value" ]]; then
            case "$secret" in
            "SSH_PUBLIC_KEY")
                jq --arg key "$value" '.ssh.public_key = $key' "$temp_json" >"$temp_json.tmp" && mv "$temp_json.tmp" "$temp_json"
                ;;
            "SYSLOG_IP")
                jq --arg ip "$value" '.syslog.server = $ip' "$temp_json" >"$temp_json.tmp" && mv "$temp_json.tmp" "$temp_json"
                ;;
            "SYSLOG_PORT")
                jq --arg port "$value" '.syslog.port = $port' "$temp_json" >"$temp_json.tmp" && mv "$temp_json.tmp" "$temp_json"
                ;;
            "GOTIFY_URL")
                jq --arg url "$value" '.gotify.url = $url' "$temp_json" >"$temp_json.tmp" && mv "$temp_json.tmp" "$temp_json"
                ;;
            "GOTIFY_TOKEN")
                jq --arg token "$value" '.gotify.token = $token' "$temp_json" >"$temp_json.tmp" && mv "$temp_json.tmp" "$temp_json"
                ;;
            esac
        fi
    done

    # Move assembled config to final location
    mv "$temp_json" "$config_file"
    chmod 600 "$config_file"

    # Cleanup GitHub auth
    gh auth logout

    log_success "Credentials fetched from GitHub"
}
