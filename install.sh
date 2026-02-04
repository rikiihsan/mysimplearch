#!/bin/bash
# =====================================================
# Arch Linux Sway + Tuigreet + Dev Environment Installer
# =====================================================

set -Eeuo pipefail

# -----------------------------------------------------
# Global variables
# -----------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/share/install-logs"
LOG_FILE="$LOG_DIR/sway-install-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$LOG_DIR"

# -----------------------------------------------------
# Logging helpers
# -----------------------------------------------------
log() {
    echo "[$(date '+%F %T')] [INFO] $*" | tee -a "$LOG_FILE"
}

warn() {
    echo "[$(date '+%F %T')] [WARN] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[$(date '+%F %T')] [ERROR] $*" | tee -a "$LOG_FILE" >&2
}

trap 'error "Script failed at line $LINENO. Check log: $LOG_FILE"' ERR

log "Starting Sway developer environment installation"
log "Script directory: $SCRIPT_DIR"
log "Log file: $LOG_FILE"

# -----------------------------------------------------
# Core packages
# -----------------------------------------------------
log "Installing core Sway & Wayland packages..."

sudo pacman -S --needed --noconfirm \
    sway swaylock swayidle swaybg waybar xorg-xwayland \
    kitty wl-clipboard brightnessctl \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
    noto-fonts noto-fonts-emoji ttf-fira-code \
    polkit-gnome \
    xdg-desktop-portal xdg-desktop-portal-wlr \
    wofi wget unzip ttf-font-awesome

# -----------------------------------------------------
# Install paru (AUR helper)
# -----------------------------------------------------
if ! command -v paru >/dev/null 2>&1; then
    log "paru not found, installing..."

    sudo pacman -S --needed --noconfirm base-devel git rustup
    rustup default stable

    TMPDIR="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$TMPDIR/paru"
    pushd "$TMPDIR/paru" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$TMPDIR"

    log "paru installed successfully"
else
    log "paru already installed"
fi

# -----------------------------------------------------
# greetd + tuigreet
# -----------------------------------------------------
log "Installing greetd + tuigreet..."
paru -S --needed --noconfirm greetd greetd-tuigreet wlogout

sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

GREETD_CONFIG_SRC="$SCRIPT_DIR/greetd/config.toml"
GREETD_CONFIG_DST="/etc/greetd/config.toml"

if [[ ! -f "$GREETD_CONFIG_SRC" ]]; then
    error "Missing greetd config: $GREETD_CONFIG_SRC"
    exit 1
fi

log "Installing greetd config..."
sudo install -Dm644 "$GREETD_CONFIG_SRC" "$GREETD_CONFIG_DST"

# -----------------------------------------------------
# PipeWire (user services)
# -----------------------------------------------------
log "Enabling PipeWire user services..."

systemctl --user enable pipewire.service 2>/dev/null || warn "pipewire.service already enabled"
systemctl --user enable pipewire-pulse.service 2>/dev/null || warn "pipewire-pulse.service already enabled"
systemctl --user enable wireplumber.service 2>/dev/null || warn "wireplumber.service already enabled"

# -----------------------------------------------------
# Browser
# -----------------------------------------------------
log "Installing lightweight browser..."
paru -S --needed --noconfirm midori-bin

# -----------------------------------------------------
# User config files
# -----------------------------------------------------
log "Installing user configuration files..."

mkdir -p "$HOME/.config"

for dir in nvim sway swaylock waybar wlogout wofi kitty mako; do
    SRC="$SCRIPT_DIR/$dir"
    DST="$HOME/.config/$dir"

    if [[ -d "$SRC" ]]; then
        log "Copying config: $dir"
        rm -rf "$DST"
        cp -r "$SRC" "$DST"
    else
        warn "Config directory not found: $SRC (skipped)"
    fi
done

# -----------------------------------------------------
# Development stack
# -----------------------------------------------------
log "Installing development tools..."

sudo pacman -S --needed --noconfirm \
    neovim git nodejs npm python go php composer \
    ripgrep fd lazygit python-black

# Go tools
log "Installing Go tools..."
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install golang.org/x/tools/cmd/goimports@latest

# npm global (user-local)
log "Configuring npm global directory..."
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
npm install -g eslint_d prettier

# Composer global tools
log "Installing Composer tools..."
composer global require squizlabs/php_codesniffer
composer global require friendsofphp/php-cs-fixer

# -----------------------------------------------------
# Persist PATH
# -----------------------------------------------------
log "Updating PATH in ~/.bashrc..."

if ! grep -q "Dev Tools PATH" "$HOME/.bashrc" 2>/dev/null; then
    {
        echo ''
        echo '# ---- Dev Tools PATH ----'
        echo 'export PATH="$PATH:$(go env GOPATH)/bin"'
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"'
        echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"'
    } >> "$HOME/.bashrc"
else
    warn "PATH block already exists in ~/.bashrc"
fi

# -----------------------------------------------------
# Nerd Font (FiraCode)
# -----------------------------------------------------
log "Installing FiraCode Nerd Font..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
pushd "$FONT_DIR" >/dev/null

if [[ ! -f "FiraCodeNerdFont-Regular.ttf" ]]; then
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
    unzip -o FiraCode.zip
    rm -f FiraCode.zip
    fc-cache -f
    log "FiraCode Nerd Font installed"
else
    warn "FiraCode Nerd Font already present"
fi

popd >/dev/null

# -----------------------------------------------------
log "Installation completed successfully"
log "Reboot to start tuigreet login"
echo
echo "✅ Sway minimal developer setup completed"
echo "📄 Log saved to: $LOG_FILE"
