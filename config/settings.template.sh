#!/bin/bash
# @Title: Settings Template
# @Author: Christian Blank (christianblank91@gmail.com)
# @License: MIT
# @Description: Template for system-wide settings. This file defines default
#              configurations and package requirements for different distributions.
#              Local settings should be generated in settings.local.sh.

# Version tracking
readonly SCRIPT_VERSION="1.0.0"
readonly VERSION_FILE="${INSTALL_DIR}/.version"

# Installation settings
readonly INSTALL_DIR="/root/.shellscripts"
readonly REQUIRED_SHELL="/bin/bash"

# Package names by distribution
declare -A PACKAGES
PACKAGES["debian"]="curl unzip duf screenfetch fonts-firacode rsyslog htop nano neofetch"
PACKAGES["ubuntu"]="curl unzip duf screenfetch fonts-firacode rsyslog htop nano neofetch"
PACKAGES["arch"]="curl unzip duf screenfetch ttf-fira-code rsyslog htop nano neofetch"
PACKAGES["alpine"]="curl unzip duf screenfetch font-fira-code rsyslog htop nano neofetch"

# Theme paths
readonly THEME_PATH="${INSTALL_DIR}/theme.json"

# Simple MOTD
readonly MOTD='
System initialized with Linux System Setup Script provided by Cyneric
------------------------------------------------
Author: Christian Blank (christianblank91@gmail.com)
License: MIT
Repository: https://github.com/Cyneric/shellscripts
'

# Optional packages that can be installed
declare -A OPTIONAL_PACKAGES
OPTIONAL_PACKAGES=(
    ["system_monitor"]="htop"
    ["text_editor"]="nano"
    ["system_info"]="neofetch"
    ["logging"]="rsyslog"
    ["notifications"]="curl"
)

# Add optional features configuration
declare -A OPTIONAL_FEATURES
OPTIONAL_FEATURES=(
    ["remote_logging"]="false"
    ["login_notifications"]="false"
)
