#!/bin/bash
# @Title: Bootstrap Script
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Version: 1.0.0
# @Description: Initial setup script that downloads and starts the installation
#              process. Detects the Linux distribution and installs required
#              prerequisites.
# @Usage: curl -sSL https://raw.githubusercontent.com/Cyneric/shellscripts/main/bootstrap.sh | sudo bash [-s -- config.json]

set -e

# Configuration
REPO_URL="https://github.com/Cyneric/shellscripts.git"
INSTALL_DIR="/root/.shellscripts"
CONFIG_FILE="${1:-}" # Optional config file parameter

# Color definitions
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

# Detect package manager
detect_package_manager() {
    if command -v apt-get >/dev/null; then
        echo "apt"
    elif command -v pacman >/dev/null; then
        echo "pacman"
    elif command -v apk >/dev/null; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# Install packages based on package manager
install_prerequisites() {
    local pkg_manager=$(detect_package_manager)

    echo -e "${BLUE}Installing prerequisites...${ENDCOLOR}"

    case $pkg_manager in
    "apt")
        apt-get update >/dev/null 2>&1
        apt-get install -y curl git >/dev/null 2>&1
        ;;
    "pacman")
        pacman -Sy --noconfirm >/dev/null 2>&1
        pacman -S --noconfirm curl git >/dev/null 2>&1
        ;;
    "apk")
        apk update >/dev/null 2>&1
        apk add --no-cache curl git >/dev/null 2>&1
        ;;
    *)
        echo -e "${RED}Unsupported package manager. Please install curl and git manually.${ENDCOLOR}"
        exit 1
        ;;
    esac
}

echo -e "${BLUE}Starting Linux system setup...${ENDCOLOR}"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root${ENDCOLOR}" >&2
    exit 1
fi

# Install prerequisites
install_prerequisites

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Clone repository
echo -e "${BLUE}Downloading setup scripts...${ENDCOLOR}"
git clone --quiet --depth 1 "$REPO_URL" "$INSTALL_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to clone repository.${ENDCOLOR}"
    exit 1
fi

# Run setup
cd "$INSTALL_DIR"
chmod +x initial_setup.sh
if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "${INSTALL_DIR}/config.json"
fi
./initial_setup.sh

echo -e "${GREEN}Installation complete! Please log out and back in for all changes to take effect.${ENDCOLOR}"
