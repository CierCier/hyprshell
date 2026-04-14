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
if [ -f "$DOTS_DIR/pkglist/base.txt" ]; then
    say "Installing base packages..."
    grep -v '^#' "$DOTS_DIR/pkglist/base.txt" | xargs $SUDO pacman -S --needed --noconfirm
fi

if [ -f "$DOTS_DIR/pkglist/aur.txt" ]; then
    say "Installing AUR packages..."
    grep -v '^#' "$DOTS_DIR/pkglist/aur.txt" | xargs paru -S --needed --noconfirm
fi

# 5. Run the main installer with auto-accept
bold "5. Running dotfiles installer..."
bash "$DOTS_DIR/install" --yes

# 6. Networking configurations (IWD + systemd-networkd)
bold "6. Configuring networking (IWD for WiFi, systemd-networkd for Ethernet)..."

# Create systemd-networkd config for Ethernet
$SUDO mkdir -p /etc/systemd/network
say "Configuring wired ethernet (DHCP)..."
$SUDO tee /etc/systemd/network/20-wired.network > /dev/null <<EOF
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes

[DHCPv4]
RouteMetric=10
EOF

# Create systemd-networkd config for Wireless (via IWD)
say "Configuring wireless (via iwd)..."
$SUDO tee /etc/systemd/network/25-wireless.network > /dev/null <<EOF
[Match]
Name=wlan*
Name=wlp*

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes

[DHCPv4]
RouteMetric=20
EOF

# Configure IWD to use its own internal network configuration or let networkd handle it
# If we use systemd-networkd, we should tell IWD to NOT do its own DHCP.
$SUDO mkdir -p /etc/iwd
$SUDO tee /etc/iwd/main.conf > /dev/null <<EOF
[General]
EnableNetworkConfiguration=false

[Network]
NameResolvingService=systemd
EOF

# 7. System configurations & Services
bold "7. Finalizing system configurations and enabling services..."

# Disable NetworkManager if it was installed (to avoid conflicts)
$SUDO systemctl disable NetworkManager.service || true
$SUDO systemctl stop NetworkManager.service || true

# Enable new networking stack
$SUDO systemctl enable iwd.service
$SUDO systemctl enable systemd-networkd.service
$SUDO systemctl enable systemd-resolved.service

# Setup symlink for resolved
$SUDO ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Other services
$SUDO systemctl enable sddm.service || true
$SUDO systemctl enable bluetooth.service || true
$SUDO systemctl enable fstrim.timer || true

# Copy kernel cmdline configs
if [ -d "$DOTS_DIR/vendor/kernel_cmdline" ]; then
    bold "Copying kernel cmdline configs to /etc/cmdline.d/..."
    $SUDO mkdir -p /etc/cmdline.d/
    $SUDO cp "$DOTS_DIR"/vendor/kernel_cmdline/*.conf /etc/cmdline.d/ || true
fi

bold "Bootstrap complete! If you are in a chroot, exit and reboot."
bold "Note: Use 'iwctl' to connect to WiFi after rebooting."
