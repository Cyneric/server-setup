#!/bin/bash
# @Title: Configuration Setup
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Description: Handles the configuration setup process by reading from a JSON
#              configuration file or prompting for values interactively.
# @Usage: Called by initial_setup.sh during installation

# Function to read JSON value
parse_json() {
    local json="$1"
    local field="$2"
    echo "$json" | jq -r "$field" 2>/dev/null || echo ""
}

# Function to prompt for missing value
prompt_value() {
    local prompt="$1"
    local current_value="$2"
    local value

    if [[ -z "$current_value" || "$current_value" == "null" ]]; then
        echo -e "${LIGHTBLUE}Enter $prompt:${ENDCOLOR}"
        read -r value
        echo "$value"
    else
        echo "$current_value"
    fi
}

# Add near the top after sourcing utils.sh
source "${SCRIPT_DIR}/modules/github_credentials.sh"

setup_configuration() {
    local config_file="${INSTALL_DIR}/config/settings.local.sh"
    local json_config="${1:-config.json}"
    local config_json="{}"
    local setup_logging="false"
    local setup_notifications="false"

    log_info "Setting up configuration..."

    # GitHub credentials option
    if prompt_user "Would you like to fetch credentials from GitHub?"; then
        echo -e "${LIGHTBLUE}Please enter your GitHub Personal Access Token:${ENDCOLOR}"
        read -rs gh_token
        echo # New line after hidden input

        if fetch_github_credentials "$gh_token" "$json_config"; then
            config_json=$(cat "$json_config")
            log_success "Credentials loaded from GitHub"
        else
            log_error "Failed to fetch GitHub credentials"
            log_info "Falling back to manual configuration"
        fi
    elif [[ -f "$json_config" ]]; then
        config_json=$(cat "$json_config")
        log_success "Found configuration file"
    else
        log_warning "No configuration file found at $json_config"
        log_info "Will prompt for all values"
    fi

    # Prompt for optional features
    if prompt_user "Would you like to set up remote logging (syslog)?"; then
        setup_logging="true"
        local syslog_ip=$(prompt_value "Syslog server IP" \
            "$(parse_json "$config_json" '.syslog.server')")
        local syslog_port=$(prompt_value "Syslog server port" \
            "$(parse_json "$config_json" '.syslog.port')")
    else
        local syslog_ip=""
        local syslog_port=""
    fi

    if prompt_user "Would you like to set up login notifications (Gotify)?"; then
        setup_notifications="true"
        local gotify_url=$(prompt_value "Gotify server URL (e.g., http://gotify.yourdomain.com)" \
            "$(parse_json "$config_json" '.gotify.url')")
        local gotify_token=$(prompt_value "Gotify application token" \
            "$(parse_json "$config_json" '.gotify.token')")
    else
        local gotify_url=""
        local gotify_token=""
    fi

    # Always prompt for SSH key as it's a core security feature
    local ssh_key=$(prompt_value "SSH public key (leave empty to skip)" \
        "$(parse_json "$config_json" '.ssh.public_key')")

    # Create local configuration
    cat >"$config_file" <<EOF
#!/bin/bash

# Generated configuration - DO NOT COMMIT

# Optional Features
readonly ENABLE_REMOTE_LOGGING="${setup_logging}"
readonly ENABLE_NOTIFICATIONS="${setup_notifications}"

# SSH Configuration
readonly SSH_PUBLIC_KEY="${ssh_key}"

# Syslog Configuration (if enabled)
readonly SYSLOG_IP="${syslog_ip}"
readonly SYSLOG_PORT="${syslog_port}"

# Gotify Notification Service (if enabled)
readonly GOTIFY_URL="${gotify_url}"
readonly GOTIFY_TOKEN="${gotify_token}"
EOF

    chmod 600 "$config_file"
    log_success "Configuration saved"
}
