#!/bin/bash

# Configuration
OUTPUT="hitmanLinux"
SOURCE="hitmanLinux.cpp"
REQUIRED_PACKAGES=(
    "gcc"
    "pkgconf"
    "gtk3"
    "libx11"
    "libayatana-appindicator"
)

# Compiler flags
CXXFLAGS=(
    "-O2"                # Optimization level 2
    "-Wall"             # Enable all warnings
    "-Wextra"           # Enable extra warnings
    "-std=c++11"        # C++11 standard
    "-fstack-protector-strong"  # Stack protection
    "-D_FORTIFY_SOURCE=2"      # Additional security checks
    "-static-libgcc"    # Static linking of libgcc
    "-static-libstdc++" # Static linking of libstdc++
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handling
set -e  # Exit on error

# Print error message and exit
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Print success message
success() {
    echo -e "${GREEN}$1${NC}"
}

# Print warning message
warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install required packages
check_and_install_packages() {
    echo "Checking for required packages..."
    
    # Check if we're running on a Debian-based system
    if ! command_exists pacman; then
        error "This script requires pacman package manager. Please install packages manually."
    fi

    # Check for sudo privileges
    if ! command_exists sudo; then
        error "sudo is required to install packages"
    fi

    local missing_packages=()
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! pacman -Qi "$package" &>/dev/null; then
            missing_packages+=("$package")
        else
            success "$package is already installed."
        fi
    done

    # Install missing packages
    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo "Installing missing packages: ${missing_packages[*]}"
        sudo pacman -Sy --noconfirm "${missing_packages[@]}" || error "Failed to install packages"
    fi
}

# Compile source code
compile_source() {
    echo "Compiling $SOURCE..."
    
    # Check if source file exists
    [ -f "$SOURCE" ] || error "Source file $SOURCE not found"

    # Set PKG_CONFIG_PATH
    export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

    # Get GTK and X11 flags
    local pkg_config_flags
    pkg_config_flags=$(pkg-config --cflags --libs gtk+-3.0 x11 ayatana-appindicator3-0.1) || error "Failed to get package config flags"

    # Compile
    g++ "${CXXFLAGS[@]}" "$SOURCE" -o "$OUTPUT" $pkg_config_flags || error "Compilation failed"
    
    # Make executable
    chmod +x "$OUTPUT" || warning "Failed to make file executable"

    success "Compilation successful! Output file: $OUTPUT"
}

# Cleanup function
cleanup() {
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}Compilation failed!${NC}"
        # Remove output file if it exists and compilation failed
        [ -f "$OUTPUT" ] && rm "$OUTPUT"
    fi
}

# Main function
main() {
    # Register cleanup function
    trap cleanup EXIT

    echo "Starting compilation process..."
    check_and_install_packages
    compile_source
    echo -e "\nBuild completed successfully!"
}

# Run main function
main