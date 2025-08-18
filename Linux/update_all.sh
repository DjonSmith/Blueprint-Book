#!/bin/bash

# System Package Updater Script
# Updates APT, Flatpak, and Snap packages

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Header
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  System Package Updater${NC}"
echo -e "${BLUE}================================${NC}"
echo

# Update APT packages
print_status "Updating APT packages..."
if command_exists apt; then
    sudo apt update && sudo apt upgrade -y
    print_success "APT packages updated successfully"
else
    print_warning "APT not found on this system"
fi

echo

# Update Flatpak packages
print_status "Updating Flatpak packages..."
if command_exists flatpak; then
    flatpak update -y
    print_success "Flatpak packages updated successfully"
else
    print_warning "Flatpak not found on this system"
fi

echo

# Update Snap packages
print_status "Updating Snap packages..."
if command_exists snap; then
    sudo snap refresh
    print_success "Snap packages updated successfully"
else
    print_warning "Snap not found on this system"
fi

echo

# Clean up APT cache (optional)
print_status "Cleaning up APT cache..."
if command_exists apt; then
    sudo apt autoremove -y
    sudo apt autoclean
    print_success "APT cleanup completed"
fi

echo
print_success "All available package managers have been updated!"
echo -e "${BLUE}================================${NC}"
