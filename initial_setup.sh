#!/bin/bash
# @Title: Initial Setup Script
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Version: 1.0.0
# @Description: Main setup orchestrator that coordinates the installation process

# Source configuration and utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/settings.template.sh"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/config/setup_config.sh"

check_existing_installation() {
    if [[ -f "${VERSION_FILE}" ]]; then
        local installed_version=$(cat "${VERSION_FILE}")
        if [[ "${installed_version}" == "${SCRIPT_VERSION}" ]]; then
            log_info "System already configured with latest version ${SCRIPT_VERSION}"
            if ! prompt_user "Do you want to reconfigure the system?"; then
                log_info "Skipping configuration. System is up to date."
                exit 0
            fi
            log_warning "Proceeding with reconfiguration..."
        else
            log_info "Updating from version ${installed_version} to ${SCRIPT_VERSION}"
        fi
    else
        log_info "Fresh installation detected"
    fi
}

update_version_file() {
    echo "${SCRIPT_VERSION}" >"${VERSION_FILE}"
    chmod 644 "${VERSION_FILE}"
}

main() {
    check_prerequisites
    check_existing_installation

    setup_directories
    setup_configuration "$@"

    # Source the local settings after configuration
    source "${INSTALL_DIR}/config/settings.local.sh"

    # Install required packages for detected distribution
    local distro=$(get_distribution)
    for package in ${PACKAGES[$distro]}; do
        install_package "$package"
    done

    # Configure system components only if needed
    configure_ssh
    configure_syslog
    setup_oh_my_posh

    # Update/install scripts only if needed
    if [[ ! -f "${INSTALL_DIR}/login.sh" ]] || prompt_user "Update login/logout scripts?"; then
        cp "${SCRIPT_DIR}/modules/login.sh" "${INSTALL_DIR}/login.sh"
        cp "${SCRIPT_DIR}/modules/logout.sh" "${INSTALL_DIR}/logout.sh"
        chmod +x "${INSTALL_DIR}/login.sh" "${INSTALL_DIR}/logout.sh"

        # Add to profile if not already present
        if ! grep -q "${INSTALL_DIR}/login.sh" ~/.profile; then
            echo -e "\n# System setup scripts" >>~/.profile
            echo -e "${INSTALL_DIR}/login.sh" >>~/.profile
        fi

        if ! grep -q "${INSTALL_DIR}/logout.sh" ~/.bash_logout; then
            echo -e "${INSTALL_DIR}/logout.sh" >>~/.bash_logout
        fi
    fi

    # Install and configure optional features
    setup_optional_packages

    # Configure remote logging if enabled
    if [[ "${ENABLE_REMOTE_LOGGING}" == "true" ]]; then
        configure_syslog
    fi

    # Configure notifications if enabled
    if [[ "${ENABLE_NOTIFICATIONS}" == "true" ]]; then
        if ! command -v curl &>/dev/null; then
            install_package "curl"
        fi
    fi

    update_version_file
    log_success "Setup completed successfully"
}

main "$@"
