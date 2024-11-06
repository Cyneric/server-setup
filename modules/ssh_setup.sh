#!/bin/bash
# @Title: SSH Setup Module
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Description: Handles SSH key configuration and management

configure_ssh() {
    local ssh_dir=~/.ssh
    local auth_keys="${ssh_dir}/authorized_keys"

    # Create .ssh directory if it doesn't exist
    if [[ ! -d "$ssh_dir" ]]; then
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"
    fi

    # Create authorized_keys if it doesn't exist
    if [[ ! -f "$auth_keys" ]]; then
        touch "$auth_keys"
        chmod 600 "$auth_keys"
    fi

    # Check if key is already configured
    if grep -Fq "${SSH_PUBLIC_KEY}" "$auth_keys"; then
        log_success "SSH key already configured"
        return 0
    fi

    if prompt_user "Do you want to add your SSH key?"; then
        # Backup existing authorized_keys
        if [[ -s "$auth_keys" ]]; then
            cp "$auth_keys" "${auth_keys}.bak"
        fi

        # Add the new key
        echo "ssh-rsa ${SSH_PUBLIC_KEY} root@${HOSTNAME}" >>"$auth_keys"
        chmod 600 "$auth_keys"

        if grep -Fq "${SSH_PUBLIC_KEY}" "$auth_keys"; then
            log_success "SSH key added to authorized_keys"
        else
            log_error "Failed to add SSH key"
            # Restore backup if it exists
            if [[ -f "${auth_keys}.bak" ]]; then
                mv "${auth_keys}.bak" "$auth_keys"
            fi
            return 1
        fi
    else
        log_warning "SSH key not added"
    fi
}
