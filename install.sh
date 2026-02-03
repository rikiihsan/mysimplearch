#!/bin/bash
# =====================================================
# Arch Linux Sway + Tuigreet + Dev Environment Installer
# =====================================================

set -euo pipefail

echo "==> Installing core Sway & Wayland packages..."

sudo pacman -S --needed --noconfirm \
    sway swaylock swayidle swaybg waybar xorg-xwayland \
    kitty wl-clipboard brightnessctl \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
    noto-fonts noto-fonts-emoji ttf-fira-code \
    polkit-gnome \
    xdg-desktop-portal xdg-desktop-portal-wlr wofi wget ttf-font-awesome

# -----------------------------------------------------
# Install paru (AUR helper) if missing
# -----------------------------------------------------
if ! command -v paru >/dev/null 2>&1; then
    echo "==> Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git rustup
    rustup default stable

    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    cd "$tmpdir/paru"
    makepkg -si --noconfirm
    cd ~
    rm -rf "$tmpdir"
fi

# -----------------------------------------------------
# Login Manager: greetd + tuigreet
# -----------------------------------------------------
echo "==> Installing greetd + tuigreet..."
paru -S --needed --noconfirm greetd greetd-tuigreet wlogout

sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

sudo cp ./greetd/config.toml /etc/greetd/config.toml

# -----------------------------------------------------
# PipeWire (user services)
# -----------------------------------------------------
echo "==> Enabling PipeWire user services..."
systemctl --user enable pipewire.service || true
systemctl --user enable pipewire-pulse.service || true
systemctl --user enable wireplumber.service || true

# -----------------------------------------------------
# Browser (lightweight & maintained)
# -----------------------------------------------------
echo "==> Installing browser..."
paru -S --needed --noconfirm midori-bin

# -----------------------------------------------------
# User configuration files
# (expects folders exist alongside this script)
# -----------------------------------------------------
echo "==> Installing user configs..."
mkdir -p ~/.config
cp -r nvim sway swaylock waybar wlogout wofi kitty mako ~/.config/

# -----------------------------------------------------
# Development tools
# -----------------------------------------------------
echo "==> Installing development stack..."

sudo pacman -S --needed --noconfirm \
    neovim git nodejs npm python go php composer \
    ripgrep fd lazygit python-black

# Go tools
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install golang.org/x/tools/cmd/goimports@latest

# npm global (user-local)
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
npm install -g eslint_d prettier

# Composer global tools
composer global require squizlabs/php_codesniffer
composer global require friendsofphp/php-cs-fixer

# -----------------------------------------------------
# Persist PATH (bash)
# -----------------------------------------------------
echo "==> Updating PATH..."

{
    echo ''
    echo '# ---- Dev Tools PATH ----'
    echo 'export PATH="$PATH:$(go env GOPATH)/bin"'
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"'
    echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"'
} >> ~/.bashrc

# -----------------------------------------------------
# Nerd Font (FiraCode)
# -----------------------------------------------------
echo "==> Installing FiraCode Nerd Font..."

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
unzip -o FiraCode.zip
rm -f FiraCode.zip
fc-cache -f

# -----------------------------------------------------
echo
echo "✅ Sway minimal developer setup completed successfully"
echo "➡️  Reboot to start tuigreet login"
