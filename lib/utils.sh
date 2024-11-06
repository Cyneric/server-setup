#!/bin/bash
# @Title: Utility Functions
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Description: Common utility functions used throughout the setup scripts.
#              Includes logging, package management, and distribution detection.

# Color definitions
declare -r RED="\e[31m"
declare -r GREEN="\e[32m"
declare -r YELLOW="\e[33m"
declare -r BLUE="\e[34m"
declare -r LIGHTBLUE="\e[94m"
declare -r CYAN="\e[46m"
declare -r ENDCOLOR="\e[0m"

# Distribution detection
get_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/alpine-release ]; then
        echo "alpine"
    else
        echo "unknown"
    fi
}

# Package manager commands
install_package() {
    local package="$1"
    local distro=$(get_distribution)

    case $distro in
    "ubuntu" | "debian")
        if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
            log_info "Installing $package..."
            apt-get install -y "$package"
        fi
        ;;
    "arch")
        if ! pacman -Q "$package" >/dev/null 2>&1; then
            log_info "Installing $package..."
            pacman -S --noconfirm "$package"
        fi
        ;;
    "alpine")
        if ! apk info -e "$package" >/dev/null 2>&1; then
            log_info "Installing $package..."
            apk add --no-cache "$package"
        fi
        ;;
    *)
        log_error "Unsupported distribution for package installation"
        return 1
        ;;
    esac
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO] $1${ENDCOLOR}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${ENDCOLOR}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${ENDCOLOR}" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${ENDCOLOR}"
}

prompt_user() {
    local prompt="$1"
    local response
    echo -e "${LIGHTBLUE}$prompt (y/n): ${ENDCOLOR}"
    read -r response
    [[ "$response" =~ ^[Yy](es)?$ ]]
}

check_prerequisites() {
    local distro=$(get_distribution)
    case $distro in
    "ubuntu" | "debian" | "arch" | "alpine")
        log_success "Supported distribution detected: $distro"
        ;;
    *)
        log_error "Unsupported distribution: $distro"
        exit 1
        ;;
    esac
}

setup_directories() {
    if [[ ! -d "$INSTALL_DIR" ]]; then
        log_info "Creating installation directory..."
        mkdir -p "$INSTALL_DIR"
    fi
}

# Check if a line exists in a file
line_exists() {
    local line="$1"
    local file="$2"
    grep -Fxq "$line" "$file" 2>/dev/null
}

# Add line to file if it doesn't exist
add_line_if_missing() {
    local line="$1"
    local file="$2"
    if ! line_exists "$line" "$file"; then
        echo "$line" >>"$file"
        return 0
    fi
    return 1
}

# Check if a package needs updating
package_needs_update() {
    local package="$1"
    local distro=$(get_distribution)

    case $distro in
    "ubuntu" | "debian")
        apt-get --just-print upgrade 2>&1 | grep -q "^Inst $package"
        ;;
    "arch")
        pacman -Qu "$package" >/dev/null 2>&1
        ;;
    "alpine")
        apk version -l '<' "$package" >/dev/null 2>&1
        ;;
    *)
        return 1
        ;;
    esac
}

# Add this function after install_package():

install_optional_package() {
    local package="$1"
    local description="$2"

    if prompt_user "Would you like to install ${description} (${package})?"; then
        install_package "$package"
        return 0
    fi
    return 1
}

# Add this function after check_prerequisites():

setup_optional_packages() {
    log_info "Checking optional packages..."

    # System monitor
    if ! command -v htop &>/dev/null; then
        install_optional_package "htop" "system monitor"
    fi

    # Text editor
    if ! command -v nano &>/dev/null; then
        install_optional_package "nano" "text editor"
    fi

    # System information display
    if ! command -v screenfetch &>/dev/null; then
        if ! command -v neofetch &>/dev/null; then
            if prompt_user "Would you like to install a system information display tool?"; then
                if prompt_user "Install neofetch? (No will install screenfetch instead)"; then
                    install_package "neofetch"
                else
                    install_package "screenfetch"
                fi
            fi
        fi
    fi
}
