#!/usr/bin/env bash
set -euo pipefail

# Hyprshell Bootstrap Script (Non-interactive)
# Designed for fresh Arch Linux installations (works in chroot).

REPO_URL="https://github.com/CierCier/hyprshell"
DOTS_DIR="$HOME/.dots"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
say() { printf '%s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# 1. Update system and install git/base-devel
bold "1. Updating system and installing base-devel/git..."
$SUDO pacman -Syu --noconfirm --needed git base-devel

# 2. Install paru (AUR helper) if not present
if ! command -v paru >/dev/null 2>&1; then
    bold "2. Installing paru (AUR helper)..."
    TEMP_DIR=$(mktemp -d)
    # paru-bin is faster to install as it doesn't require rust to build
    git clone https://aur.archlinux.org/paru-bin.git "$TEMP_DIR"
    (cd "$TEMP_DIR" && makepkg -si --noconfirm)
    rm -rf "$TEMP_DIR"
fi

# 3. Clone repository
bold "3. Cloning hyprshell repository..."
if [ ! -d "$DOTS_DIR" ]; then
    git clone --recursive "$REPO_URL" "$DOTS_DIR"
else
    say "Repository already exists at $DOTS_DIR"
    (cd "$DOTS_DIR" && git pull && git submodule update --init --recursive)
fi

# 4. Install packages from pkglist
bold "4. Installing packages from pkglist..."
# Pacman packages
if [ -f "$DOTS_DIR/pkglist/base.txt" ]; then
    say "Installing base packages..."
    # Filter out comments and empty lines, then install
    grep -v '^#' "$DOTS_DIR/pkglist/base.txt" | xargs $SUDO pacman -S --needed --noconfirm
fi

# AUR packages
if [ -f "$DOTS_DIR/pkglist/aur.txt" ]; then
    say "Installing AUR packages..."
    grep -v '^#' "$DOTS_DIR/pkglist/aur.txt" | xargs paru -S --needed --noconfirm
fi

# 5. Run the main installer with auto-accept
bold "5. Running dotfiles installer..."
bash "$DOTS_DIR/install" --yes

# 6. System configurations
bold "6. Finalizing system configurations..."

# Enable services
say "Enabling system services..."
$SUDO systemctl enable sddm.service || true
$SUDO systemctl enable NetworkManager.service || true
$SUDO systemctl enable bluetooth.service || true
$SUDO systemctl enable fstrim.timer || true

# Copy kernel cmdline configs if they exist
if [ -d "$DOTS_DIR/vendor/kernel_cmdline" ]; then
    bold "Copying kernel cmdline configs to /etc/cmdline.d/..."
    $SUDO mkdir -p /etc/cmdline.d/
    $SUDO cp "$DOTS_DIR"/vendor/kernel_cmdline/*.conf /etc/cmdline.d/ || true
fi

# Add any custom udev rules or etc configs here if they are ever added to the repo
# For example:
# if [ -f "$DOTS_DIR/etc/99-custom.rules" ]; then
#     $SUDO cp "$DOTS_DIR/etc/99-custom.rules" /etc/udev/rules.d/
# fi

bold "Bootstrap complete! If you are in a chroot, exit and reboot."
bold "If you are in a live system, just reboot."
